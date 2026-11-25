import 'dart:async';

import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/features/notifications/data/notification_service.dart';
import 'package:uuid/uuid.dart';

/// Transaction-like funding boundary for the demo.
///
/// Every mutation is serialized through one lock, and the remaining amount and
/// wallet balance are recomputed inside that lock. A retry with the same
/// idempotency key returns the original stake without posting another journal.
class FundingService {
  FundingService(this._db, {NotificationService? notifications})
      : _notifications = notifications ?? NotificationService(_db);

  final MockDb _db;
  final NotificationService _notifications;
  Future<void>? _tail;

  Future<T> _locked<T>(Future<T> Function() action) {
    final gate = Completer<void>();
    final next = gate.future;
    final previous = _tail ?? Future<void>.value();
    _tail = next;
    return previous.then((_) async {
      try {
        return await action();
      } finally {
        if (!gate.isCompleted) gate.complete();
      }
    });
  }

  Future<Stake> fund({
    required String loanId,
    required String lenderId,
    required int amountPaisa,
    required String idempotencyKey,
    DateTime? now,
  }) =>
      _locked(() async {
        final replay = _db.stakeByKey(idempotencyKey);
        if (replay != null) {
          if (replay.lenderId != lenderId) {
            throw const AppFailure(
              'forbidden',
              'This funding key belongs to another lender.',
            );
          }
          return replay;
        }

        if (lenderId.isEmpty) {
          throw const AppFailure('unauthorized', 'Please sign in again.');
        }
        if (amountPaisa < ProductRules.minStakePaisa) {
          throw AppFailure('below_minimum', messageFor('below_minimum'));
        }
        if (idempotencyKey.isEmpty) {
          throw const AppFailure(
            'validation_error',
            'A funding request needs an idempotency key.',
          );
        }

        final timestamp = now ?? DemoClock.instance.now;
        var loan = _db.loan(loanId);
        if (loan == null) {
          throw const AppFailure('not_found', 'We could not find that loan.');
        }
        await _expireUnlocked(loan, timestamp);
        loan = _db.loan(loanId);
        if (loan == null || loan.status != LoanStatus.open) {
          throw const AppFailure(
            'invalid_transition',
            'This loan is no longer open for funding.',
          );
        }

        final remaining = loan.amountPaisa - loan.fundedPaisa;
        if (amountPaisa > remaining) {
          throw AppFailure(
            'exceeds_remaining',
            messageFor('exceeds_remaining'),
          );
        }
        final wallet = LedgerAccount.userWallet(lenderId);
        if (_db.balanceFor(wallet) < amountPaisa) {
          throw AppFailure(
            'insufficient_balance',
            messageFor('insufficient_balance'),
          );
        }

        final stakeId = 'stake-${const Uuid().v4()}';
        final journalId = 'txn-fund-$stakeId';
        final receipt = await _db.postJournal(
          journalId: journalId,
          paymentIntentId: 'pi-fund-$stakeId',
          idempotencyKey: idempotencyKey,
          kind: JournalKind.fund,
          intentKind: PaymentIntentKind.withdrawal,
          userId: lenderId,
          referenceId: loanId,
          amountPaisa: amountPaisa,
          entries: [
            LedgerEntry(
              id: '$journalId-1',
              journalId: journalId,
              accountId: wallet,
              amountPaisa: -amountPaisa,
            ),
            LedgerEntry(
              id: '$journalId-2',
              journalId: journalId,
              accountId: LedgerAccount.loanEscrow(loanId),
              amountPaisa: amountPaisa,
            ),
          ],
          now: timestamp,
        );

        final stake = Stake(
          id: stakeId,
          loanId: loanId,
          lenderId: lenderId,
          amountPaisa: amountPaisa,
          idempotencyKey: idempotencyKey,
          fundingJournalId: receipt.journalId,
          createdAt: timestamp,
        );
        await _db.setStake(stake);

        final newTotal = loan.fundedPaisa + amountPaisa;
        final completed = newTotal == loan.amountPaisa;
        if (completed) LoanTransitions.check(loan.status, LoanStatus.funded);
        await _db.setLoan(
          loan.copyWith(
            fundedPaisa: newTotal,
            status: completed ? LoanStatus.funded : loan.status,
            fundedAt: completed ? timestamp : null,
          ),
        );
        if (completed) {
          await _notifications.notify(
            userId: loan.borrowerId,
            type: NotificationType.loanFunded,
            title: 'Loan fully funded',
            body: 'Lenders have filled your ${loan.purpose} loan. '
                'Sign the agreement to receive the disbursement.',
            id: 'notif-loanFunded-${loan.id}',
            referenceId: loan.id,
            route: '/borrower/loan-agreement/${loan.id}',
            now: timestamp,
          );
        }
        return stake;
      });

  Future<int> expireLoan(String loanId, {DateTime? now}) =>
      _locked(() async {
        final loan = _db.loan(loanId);
        if (loan == null) return 0;
        return _expireUnlocked(loan, now ?? DemoClock.instance.now);
      });

  /// Demo stand-in for a scheduled deadline job. Track B runs this server-side.
  Future<int> expireAll({DateTime? now}) => _locked(() async {
        var released = 0;
        final timestamp = now ?? DemoClock.instance.now;
        for (final loan in List<Loan>.from(_db.loans.values)) {
          released += await _expireUnlocked(loan, timestamp);
        }
        return released;
      });

  Future<int> _expireUnlocked(Loan loan, DateTime now) async {
    if (loan.status != LoanStatus.open ||
        !loan.isDeadlinePassed(now)) {
      return 0;
    }

    for (final stake in _db.stakesForLoan(loan.id)) {
      if (!stake.isActive) continue;
      final original = _db.journal(stake.fundingJournalId);
      if (original == null) continue;

      final journalId = 'txn-expire-${stake.id}';
      final reversed = original.entries
          .map(
            (entry) => LedgerEntry(
              id: '${entry.id}-rev-${stake.id}',
              journalId: journalId,
              accountId: entry.accountId,
              amountPaisa: -entry.amountPaisa,
            ),
          )
          .toList(growable: false);
      final receipt = await _db.postJournal(
        journalId: journalId,
        paymentIntentId: 'pi-expire-${stake.id}',
        idempotencyKey: 'expire-${stake.id}',
        kind: JournalKind.reversal,
        intentKind: PaymentIntentKind.topup,
        userId: stake.lenderId,
        referenceId: stake.id,
        amountPaisa: stake.amountPaisa,
        entries: reversed,
        reversalOfId: original.id,
        now: now,
      );
      await _db.setStake(
        stake.copyWith(
          status: 'returned',
          returnedAt: now,
          reversalJournalId: receipt.journalId,
        ),
      );
    }

    LoanTransitions.check(loan.status, LoanStatus.expired);
    await _db.setLoan(
      loan.copyWith(
        status: LoanStatus.expired,
        fundedPaisa: 0,
        fundedAt: null,
      ),
    );
    await _notifications.notify(
      userId: loan.borrowerId,
      type: NotificationType.loanExpired,
      title: 'Funding window closed',
      body: 'Your ${loan.purpose} loan was not fully funded in time. '
          'All lender stakes were returned.',
      id: 'notif-loanExpired-${loan.id}',
      referenceId: loan.id,
      route: '/borrower/home',
      now: now,
    );
    for (final stake in _db.stakesForLoan(loan.id)) {
      await _notifications.notify(
        userId: stake.lenderId,
        type: NotificationType.loanExpired,
        title: 'Stake returned',
        body: 'The loan expired before funding completed. '
            'Your stake was returned to your wallet.',
        id: 'notif-loanExpired-${loan.id}-${stake.id}',
        referenceId: stake.id,
        route: '/stakes/${stake.id}',
        now: now,
      );
    }
    return 1;
  }
}
