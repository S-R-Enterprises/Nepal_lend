import 'dart:async';

import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/features/notifications/data/notification_service.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';

/// Result of one instalment payment, including the exact pro-rata split.
class RepaymentOutcome {
  const RepaymentOutcome({
    required this.loan,
    required this.instalment,
    required this.receipt,
    required this.feePaisa,
    required this.lenderCount,
  });

  final Loan loan;
  final Instalment instalment;
  final PaymentReceipt receipt;
  final int feePaisa;
  final int lenderCount;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'loan': loan.toJson(),
        'instalment': instalment.toJson(),
        'receipt': receipt.toJson(),
        'feePaisa': feePaisa,
        'lenderCount': lenderCount,
      };

  factory RepaymentOutcome.fromJson(Map<String, dynamic> json) =>
      RepaymentOutcome(
        loan: Loan.fromJson(json['loan'] as Map<String, dynamic>),
        instalment:
            Instalment.fromJson(json['instalment'] as Map<String, dynamic>),
        receipt:
            PaymentReceipt.fromJson(json['receipt'] as Map<String, dynamic>),
        feePaisa: (json['feePaisa'] as num?)?.toInt() ?? 0,
        lenderCount: (json['lenderCount'] as num?)?.toInt() ?? 0,
      );
}

/// Result of the nightly journal check used by the demo jobs screen.
class ReconciliationOutcome {
  const ReconciliationOutcome({
    required this.journalsChecked,
    required this.unbalancedJournalIds,
    required this.negativeWalletAccounts,
  });

  final int journalsChecked;
  final List<String> unbalancedJournalIds;
  final List<String> negativeWalletAccounts;

  bool get isClean =>
      unbalancedJournalIds.isEmpty && negativeWalletAccounts.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'journalsChecked': journalsChecked,
        'unbalancedJournalIds': unbalancedJournalIds,
        'negativeWalletAccounts': negativeWalletAccounts,
        'clean': isClean,
      };

  factory ReconciliationOutcome.fromJson(Map<String, dynamic> json) =>
      ReconciliationOutcome(
        journalsChecked: (json['journalsChecked'] as num?)?.toInt() ?? 0,
        unbalancedJournalIds: (json['unbalancedJournalIds'] as List<dynamic>? ??
                const <dynamic>[])
            .map((item) => item.toString())
            .toList(growable: false),
        negativeWalletAccounts:
            (json['negativeWalletAccounts'] as List<dynamic>? ??
                    const <dynamic>[])
                .map((item) => item.toString())
                .toList(growable: false),
      );
}

/// Transaction-like repayment boundary for the demo.
///
/// The borrower pays one exact instalment. Principal and interest are split
/// across active stakes with the largest-remainder method, the platform fee is
/// removed from the interest before lenders are credited, and every paisa is
/// recorded in a single zero-sum journal. Mutations are serialized so two
/// simultaneous calls cannot pay the same instalment twice.
class RepaymentService {
  RepaymentService(this._db, {NotificationService? notifications})
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

  Future<RepaymentOutcome> pay({
    required String loanId,
    required String borrowerId,
    required int instalmentNumber,
    required int amountPaisa,
    required String provider,
    required String idempotencyKey,
    DateTime? now,
  }) =>
      _locked(() async {
        if (idempotencyKey.trim().isEmpty) {
          throw const AppFailure(
            'validation_error',
            'A repayment needs an idempotency key.',
          );
        }

        final replay = _db.receipts[idempotencyKey];
        if (replay != null) {
          if (replay.kind != PaymentIntentKind.repayment ||
              replay.referenceId != loanId ||
              replay.amountPaisa != amountPaisa) {
            throw const AppFailure(
              'forbidden',
              'This repayment key belongs to another request.',
            );
          }
          final loan = _db.loan(loanId);
          if (loan == null) {
            throw const AppFailure('not_found', 'We could not find that loan.');
          }
          final replayedInstalment = _instalment(loan, instalmentNumber);
          return RepaymentOutcome(
            loan: loan,
            instalment: replayedInstalment,
            receipt: replay.copyWith(replayed: true),
            feePaisa: Money.feeForInterest(replayedInstalment.interestPaisa),
            lenderCount: _db.stakesForLoan(loanId).length,
          );
        }

        final timestamp = now ?? DemoClock.instance.now;
        final loan = _db.loan(loanId);
        if (loan == null || loan.borrowerId != borrowerId) {
          throw const AppFailure(
            'not_found',
            'We could not find that loan application.',
          );
        }
        if (loan.status != LoanStatus.active &&
            loan.status != LoanStatus.overdue) {
          throw const AppFailure(
            'invalid_transition',
            'This loan is not ready for repayments.',
          );
        }

        final instalment = _instalment(loan, instalmentNumber);
        if (instalment.isPaid) {
          throw AppFailure(
            'already_paid',
            'Instalment $instalmentNumber is already paid.',
          );
        }
        final next = loan.nextInstalment;
        if (next == null || next.number != instalment.number) {
          throw AppFailure(
            'invalid_transition',
            'Pay instalment ${next?.number ?? 0} first.',
          );
        }
        if (amountPaisa != instalment.totalPaisa) {
          throw const AppFailure(
            'invalid_amount',
            'Pay the exact instalment amount shown on this screen.',
          );
        }

        final stakes = _db.stakesForLoan(loanId)
          ..sort((a, b) => (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        final activeStakes = stakes.where((stake) => stake.isActive).toList();
        if (activeStakes.isEmpty) {
          throw const AppFailure(
            'invalid_transition',
            'This loan has no active lender stakes to repay.',
          );
        }

        final wallet = LedgerAccount.userWallet(borrowerId);
        if (_db.balanceFor(wallet) < amountPaisa) {
          throw AppFailure(
            'insufficient_balance',
            messageFor('insufficient_balance'),
          );
        }

        final weights = activeStakes
            .map((stake) => stake.amountPaisa)
            .toList(growable: false);
        final principalShares = Money.splitProRata(
          amountPaisa: instalment.principalPaisa,
          weights: weights,
        );
        final interestShares = Money.splitProRata(
          amountPaisa: instalment.interestPaisa,
          weights: weights,
        );
        final feePaisa = Money.feeForInterest(instalment.interestPaisa);
        final feeShares = Money.splitProRata(
          amountPaisa: feePaisa,
          weights: interestShares,
        );

        final journalId = 'txn-repay-${instalment.id}';
        final entries = <LedgerEntry>[
          LedgerEntry(
            id: '$journalId-borrower',
            journalId: journalId,
            accountId: wallet,
            amountPaisa: -amountPaisa,
          ),
        ];
        for (var i = 0; i < activeStakes.length; i++) {
          final netLenderPaisa =
              principalShares[i] + interestShares[i] - feeShares[i];
          entries.add(
            LedgerEntry(
              id: '$journalId-lender-${activeStakes[i].id}',
              journalId: journalId,
              accountId: LedgerAccount.userWallet(activeStakes[i].lenderId),
              amountPaisa: netLenderPaisa,
            ),
          );
        }
        entries.add(
          LedgerEntry(
            id: '$journalId-fee',
            journalId: journalId,
            accountId: LedgerAccount.platformFee,
            amountPaisa: feePaisa,
          ),
        );

        final receipt = await _db.postJournal(
          journalId: journalId,
          paymentIntentId: 'pi-repay-${instalment.id}',
          idempotencyKey: idempotencyKey,
          kind: JournalKind.repayment,
          intentKind: PaymentIntentKind.repayment,
          userId: borrowerId,
          referenceId: loanId,
          amountPaisa: amountPaisa,
          entries: entries,
          now: timestamp,
          provider: provider,
        );

        for (var i = 0; i < activeStakes.length; i++) {
          final stake = activeStakes[i];
          await _db.setStake(
            stake.copyWith(
              principalRepaidPaisa:
                  stake.principalRepaidPaisa + principalShares[i],
              interestRepaidPaisa:
                  stake.interestRepaidPaisa + interestShares[i],
              feePaidPaisa: stake.feePaidPaisa + feeShares[i],
              lastRepaymentJournalId: receipt.journalId,
            ),
          );
        }

        final paidInstalment = instalment.copyWith(
          status: 'paid',
          paidAt: timestamp,
          paymentJournalId: receipt.journalId,
          paymentProvider: provider,
        );
        final instalments = loan.instalments
            .map((item) => item.number == instalment.number ? paidInstalment : item)
            .toList(growable: false);
        final allPaid =
            instalments.isNotEmpty && instalments.every((item) => item.isPaid);

        LoanStatus newStatus = LoanStatus.active;
        if (allPaid) {
          if (loan.status == LoanStatus.overdue) {
            LoanTransitions.check(loan.status, LoanStatus.active);
          }
          LoanTransitions.check(LoanStatus.active, LoanStatus.repaid);
          newStatus = LoanStatus.repaid;
        } else if (loan.status == LoanStatus.overdue) {
          LoanTransitions.check(loan.status, LoanStatus.active);
        }

        final updated = loan.copyWith(
          status: newStatus,
          instalments: instalments,
          lastRepaymentAt: timestamp,
        );
        await _db.setLoan(updated);

        await _notifications.notify(
          userId: borrowerId,
          type: NotificationType.paymentReceived,
          title: 'Repayment recorded',
          body: 'Instalment ${instalment.number} of ${formatNPR(amountPaisa)} '
              'was paid with ${_providerLabel(provider)}.',
          id: 'notif-repayment-${instalment.id}-borrower',
          referenceId: loanId,
          route: '/borrower/repay/$loanId',
          now: timestamp,
        );

        for (var i = 0; i < activeStakes.length; i++) {
          final stake = activeStakes[i];
          final netPaisa =
              principalShares[i] + interestShares[i] - feeShares[i];
          await _notifications.notify(
            userId: stake.lenderId,
            type: NotificationType.paymentReceived,
            title: 'Repayment received',
            body: '${formatNPR(netPaisa)} from instalment '
                '${instalment.number} (fee ${formatNPR(feeShares[i])}).',
            id: 'notif-repayment-${instalment.id}-${stake.id}',
            referenceId: stake.id,
            route: '/stakes/${stake.id}',
            now: timestamp,
          );
        }

        if (allPaid) {
          await _notifications.notify(
            userId: borrowerId,
            type: NotificationType.paymentReceived,
            title: 'Loan fully repaid',
            body: 'All ${instalments.length} instalments are paid. '
                'Your loan is now closed.',
            id: 'notif-repaid-$loanId',
            referenceId: loanId,
            route: '/borrower/repay/$loanId',
            now: timestamp,
          );
        }

        return RepaymentOutcome(
          loan: updated,
          instalment: paidInstalment,
          receipt: receipt,
          feePaisa: feePaisa,
          lenderCount: activeStakes.length,
        );
      });

  /// Demo stand-in for a reminder job (3 days before, due day, after due).
  Future<int> sendReminders({DateTime? now}) => _locked(() async {
        final timestamp = now ?? DemoClock.instance.now;
        var sent = 0;
        for (final loan in List<Loan>.from(_db.loans.values)) {
          if (loan.status != LoanStatus.active &&
              loan.status != LoanStatus.overdue) {
            continue;
          }
          final instalment = loan.nextInstalment;
          if (instalment == null) continue;
          final days = instalment.dueDate
              .difference(DateTime(timestamp.year, timestamp.month, timestamp.day))
              .inDays;
          final isReminder = days == 3 || days == 0 || days < 0;
          if (!isReminder) continue;
          final title = switch (days) {
            3 => 'Payment in 3 days',
            0 => 'Payment due today',
            _ => 'Payment overdue',
          };
          await _notifications.notify(
            userId: loan.borrowerId,
            type: NotificationType.paymentDue,
            title: title,
            body: 'Instalment ${instalment.number} of '
                '${formatNPR(instalment.totalPaisa)} is due '
                '${_dateKey(instalment.dueDate)}.',
            id: 'notif-paymentDue-${instalment.id}-${_dateKey(timestamp)}',
            referenceId: loan.id,
            route: '/borrower/repay/${loan.id}',
            now: timestamp,
          );
          sent++;
        }
        return sent;
      });

  /// Demo stand-in for the day-after-due overdue marker.
  Future<int> markOverdue({DateTime? now}) => _locked(() async {
        final timestamp = now ?? DemoClock.instance.now;
        var changed = 0;
        for (final loan in List<Loan>.from(_db.loans.values)) {
          if (loan.status != LoanStatus.active) continue;
          final instalment = loan.nextInstalment;
          if (instalment == null) continue;
          final graceDeadline = instalment.dueDate.add(
            const Duration(days: ProductRules.graceDaysBeforeOverdue),
          );
          if (!timestamp.isAfter(graceDeadline)) continue;
          LoanTransitions.check(loan.status, LoanStatus.overdue);
          await _db.setLoan(loan.copyWith(status: LoanStatus.overdue));
          await _notifications.notify(
            userId: loan.borrowerId,
            type: NotificationType.paymentDue,
            title: 'Payment overdue',
            body: 'Instalment ${instalment.number} is now overdue. '
                'Pay it with your simulated wallet to continue.',
            id: 'notif-overdue-${instalment.id}',
            referenceId: loan.id,
            route: '/borrower/repay/${loan.id}',
            now: timestamp,
          );
          changed++;
        }
        return changed;
      });

  /// Nightly reconciliation check: every journal must sum to zero and no user
  /// wallet may be negative. Returns the offending ids for the demo jobs view.
  Future<ReconciliationOutcome> reconcile() => _locked(() async {
        final unbalanced = _db.journals
            .where((journal) => journal.sumPaisa != 0)
            .map((journal) => journal.id)
            .toList(growable: false);
        final walletIds = <String>{};
        for (final journal in _db.journals) {
          for (final entry in journal.entries) {
            if (LedgerAccount.isUserWallet(entry.accountId)) {
              walletIds.add(entry.accountId);
            }
          }
        }
        final negative = walletIds
            .where((accountId) => _db.balanceFor(accountId) < 0)
            .toList()
          ..sort();
        return ReconciliationOutcome(
          journalsChecked: _db.journals.length,
          unbalancedJournalIds: unbalanced,
          negativeWalletAccounts: List<String>.unmodifiable(negative),
        );
      });

  Instalment _instalment(Loan loan, int number) {
    for (final item in loan.instalments) {
      if (item.number == number) return item;
    }
    throw const AppFailure(
      'not_found',
      'We could not find that instalment.',
    );
  }

  String _providerLabel(String provider) => switch (provider) {
        'khalti' => 'Khalti',
        _ => 'eSewa',
      };

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
