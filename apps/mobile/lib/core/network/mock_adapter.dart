import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/features/lending/data/funding_service.dart';
import 'package:nepal_lend/features/loans/data/loan_terms.dart';
import 'package:nepal_lend/features/notifications/data/notification_service.dart';
import 'package:nepal_lend/features/repayments/data/repayment_service.dart';
import 'package:nepal_lend/features/loans/data/risk_service.dart';
import 'package:uuid/uuid.dart';

/// A Dio adapter that serves canned API responses so the whole app can be
/// exercised with `ENV=mock` — no Firebase, no backend, no cloud cost.
class MockAdapter implements HttpClientAdapter {
  MockAdapter(this._db)
      : _fundingService = FundingService(_db),
        _repaymentService = RepaymentService(_db),
        _notifications = NotificationService(_db);

  final MockDb _db;
  final FundingService _fundingService;
  final RepaymentService _repaymentService;
  final NotificationService _notifications;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await _db.ensureLoaded();

    var path = options.uri.path;
    const prefix = '/api/v1';
    if (path.startsWith(prefix)) path = path.substring(prefix.length);
    final method = options.method.toUpperCase();
    final query = options.queryParameters;
    final body = options.data is Map
        ? Map<String, dynamic>.from(options.data as Map)
        : <String, dynamic>{};

    // Simulate network latency so loading states are visible in demos.
    await Future<void>.delayed(const Duration(milliseconds: 80));

    if (method == 'DELETE' && path.startsWith('/me/devices')) {
      return _json(200, {'unregistered': true});
    }

    // KYC document creation mirrors the blueprint's signed-upload exchange.
    // Mock mode has no cloud bucket, so the local path is echoed back.
    if (method == 'POST' && path == '/me/kyc/documents') {
      final step = _parseStep(body['step']);
      if (step == null) {
        return _json(422, {
          'error': 'validation_error',
          'message': 'Unknown KYC step.',
        });
      }
      return _json(200, {
        'documentId': 'doc-${step.name}',
        'step': step.name,
        'uploadUrl': 'mock://${step.name}',
        'localPath': body['localPath'],
        'expiresInSeconds': 900,
      });
    }

    // POST /me/kyc/steps/{stepId}/submit
    if (method == 'POST' &&
        path.startsWith('/me/kyc/steps/') &&
        path.endsWith('/submit')) {
      final segments = path.split('/');
      final step = segments.length > 4 ? _parseStep(segments[4]) : null;
      if (step == null) {
        return _json(404, {
          'error': 'not_found',
          'message': 'Unknown KYC step.',
        });
      }
      try {
        final profile = (_db.kycProfile ?? KycProfile.initial()).submit(
          step,
          documentPath: body['documentPath'] as String?,
          documentName: body['documentName'] as String?,
          newDetails: _stringMap(body['details']),
        );
        await _db.setKyc(profile);
        await _notifyKycIfVerified(profile);
        return _json(200, profile.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    // Demo admin decision endpoints. Track B replaces these with a real
    // authenticated admin API and an audit-logged document viewer.
    if (method == 'POST' && path == '/me/kyc/admin/decide') {
      final step = _parseStep(body['step']);
      final decision = _parseStatus(body['decision']);
      if (step == null || decision == null) {
        return _json(422, {
          'error': 'validation_error',
          'message': 'Choose a step and a decision.',
        });
      }
      try {
        final profile = (_db.kycProfile ?? KycProfile.initial()).decide(
          step,
          decision,
          reason: body['reason'] as String?,
        );
        await _db.setKyc(profile);
        await _notifyKycIfVerified(profile);
        return _json(200, profile.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'POST' && path == '/me/kyc/admin/approve-all') {
      final profile =
          (_db.kycProfile ?? KycProfile.initial()).approveAll();
      await _db.setKyc(profile);
      return _json(200, profile.toJson());
    }

    // Lender flow. Risk is recomputed server-side at application time; lenders
    // only see the stored assessment and cannot choose a grade or rate.
    String? param(String key) => body[key] as String? ?? query[key];
    int? intParam(String key) => int.tryParse(param(key) ?? '');

    if (method == 'GET' && path == '/loans/browse') {
      try {
        _requireLender();
        await _fundingService.expireAll();
        var items = _db.loans.values.where((loan) {
          final band = param('riskBand');
          if (band != null &&
              band.isNotEmpty &&
              loan.riskBand?.name != band) {
            return false;
          }
          final min = intParam('minAmountPaisa');
          if (min != null && loan.amountPaisa < min) return false;
          final max = intParam('maxAmountPaisa');
          if (max != null && loan.amountPaisa > max) return false;
          final tenor = intParam('maxTenorMonths');
          if (tenor != null && loan.tenorMonths > tenor) return false;
          // Lenders only see loans that are actually open for funding.
          return loan.status == LoanStatus.open && loan.remainingPaisa > 0;
        }).toList();

        switch (param('sort')) {
          case 'amountAsc':
            items.sort((a, b) => a.amountPaisa.compareTo(b.amountPaisa));
          case 'amountDesc':
            items.sort((a, b) => b.amountPaisa.compareTo(a.amountPaisa));
          case 'risk':
            items.sort((a, b) =>
                (a.riskBand ?? RiskBand.high).index
                    .compareTo((b.riskBand ?? RiskBand.high).index));
          default:
            items.sort((a, b) => (b.createdAt ??
                    DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(
                    a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        }
        return _json(200, {
          'items': items.map((loan) => loan.toJson()).toList(),
        });
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'GET' && path.startsWith('/loans/browse/')) {
      try {
        _requireLender();
        final id = path.split('/').last;
        await _fundingService.expireLoan(id);
        final loan = _db.loan(id);
        if (loan == null) {
          throw const AppFailure('not_found', 'We could not find that loan.');
        }
        return _json(200, loan.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'POST' &&
        path.startsWith('/loans/') &&
        path.endsWith('/fund')) {
      try {
        final user = _requireLender();
        final loanId = path.split('/')[2];
        final amount = (body['amountPaisa'] as num?)?.toInt() ?? 0;
        final key = (body['idempotencyKey'] as String?)?.trim().isNotEmpty ==
                true
            ? body['idempotencyKey'] as String
            : options.headers['Idempotency-Key'] as String? ??
                const Uuid().v4();
        final stake = await _fundingService.fund(
          loanId: loanId,
          lenderId: user.id,
          amountPaisa: amount,
          idempotencyKey: key,
        );
        return _json(200, stake.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'GET' && path == '/stakes/mine') {
      try {
        final user = _requireLender();
        final stakes = _db.stakesForLender(user.id)
          ..sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        return _json(200, {
          'items': stakes.map((stake) => stake.toJson()).toList(),
        });
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'GET' && path.startsWith('/stakes/')) {
      try {
        final user = _requireLender();
        final stake = _db.stake(path.split('/').last);
        if (stake == null || stake.lenderId != user.id) {
          throw const AppFailure('not_found', 'We could not find that stake.');
        }
        final loan = _db.loan(stake.loanId);
        if (loan == null) {
          throw const AppFailure('not_found', 'We could not find that loan.');
        }
        return _json(200, {
          'stake': stake.toJson(),
          'loan': loan.toJson(),
        });
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'POST' && path == '/jobs/expire-loans') {
      final expired = await _fundingService.expireAll();
      return _json(200, {'expired': expired});
    }

    if (method == 'POST' && path == '/jobs/send-reminders') {
      final sent = await _repaymentService.sendReminders();
      return _json(200, {'sent': sent});
    }

    if (method == 'POST' && path == '/jobs/mark-overdue') {
      final changed = await _repaymentService.markOverdue();
      return _json(200, {'changed': changed});
    }

    if (method == 'POST' && path == '/jobs/reconcile') {
      final result = await _repaymentService.reconcile();
      return _json(200, result.toJson());
    }

    // Borrower loan flow. Risk is computed here, not trusted from the client.
    if (method == 'POST' && path == '/loans/applications') {
      try {
        final user = _requireBorrower();
        final purpose = (body['purpose'] as String? ?? '').trim();
        final amount = (body['amountPaisa'] as num?)?.toInt() ?? 0;
        final tenor = (body['tenorMonths'] as num?)?.toInt() ?? 0;
        final income = (body['monthlyIncomePaisa'] as num?)?.toInt() ?? 0;
        if (purpose.isEmpty) {
          throw const AppFailure(
            'validation_error',
            'Tell lenders what this loan is for.',
          );
        }
        if (amount < ProductRules.minLoanPaisa ||
            amount > ProductRules.maxLoanPaisa) {
          throw const AppFailure(
            'invalid_amount',
            'Enter an amount between NPR 10,000 and NPR 5,00,000.',
          );
        }
        if (tenor < 3 || tenor > 60) {
          throw const AppFailure(
            'invalid_tenor',
            'Choose a tenor between 3 and 60 months.',
          );
        }
        if (income <= 0) {
          throw const AppFailure(
            'validation_error',
            'Enter your monthly income.',
          );
        }

        final assessment = RiskService.assess(
          LoanRiskInput(
            amountPaisa: amount,
            tenorMonths: tenor,
            monthlyIncomePaisa: income,
            kycVerified: user.isVerified,
          ),
        );
        final now = DemoClock.instance.now;
        final loan = Loan(
          id: 'loan-${const Uuid().v4()}',
          borrowerId: user.id,
          purpose: purpose,
          amountPaisa: amount,
          tenorMonths: tenor,
          rateBps: assessment.rateBps,
          status: assessment.requiresReview
              ? LoanStatus.pendingReview
              : LoanStatus.open,
          borrowerName: user.name?.trim().isNotEmpty == true
              ? user.name
              : 'Verified borrower',
          monthlyIncomePaisa: income,
          riskGrade: assessment.grade,
          riskBand: assessment.band,
          assessment: assessment,
          fundingDeadline:
              now.add(const Duration(days: ProductRules.fundingWindowDays)),
          createdAt: now,
        );
        await _db.setLoan(loan);
        return _json(200, loan.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'GET' && path == '/loans/mine') {
      try {
        final user = _requireBorrower();
        final loans = _db.loansFor(user.id)
          ..sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        return _json(200, {'loans': loans.map((loan) => loan.toJson()).toList()});
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'POST' &&
        path.startsWith('/loans/') &&
        path.endsWith('/submit')) {
      try {
        final user = _requireBorrower();
        final loan = _ownedLoan(path.split('/')[2], user.id);
        if (loan.status == LoanStatus.open) return _json(200, loan.toJson());
        LoanTransitions.check(loan.status, LoanStatus.open);
        final updated = loan.copyWith(status: LoanStatus.open);
        await _db.setLoan(updated);
        return _json(200, updated.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    // Demo reviewer for grade D / high-value applications.
    if (method == 'POST' &&
        path.startsWith('/loans/') &&
        path.endsWith('/admin/approve')) {
      try {
        final user = _requireBorrower();
        final loan = _ownedLoan(path.split('/')[2], user.id);
        if (loan.status == LoanStatus.open) return _json(200, loan.toJson());
        LoanTransitions.check(loan.status, LoanStatus.open);
        final updated = loan.copyWith(status: LoanStatus.open);
        await _db.setLoan(updated);
        return _json(200, updated.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    // Signing is only available after lenders have filled escrow. It records
    // the terms, exact instalment schedule and a zero-sum escrow → wallet
    // disbursement journal. The loan id is the idempotency key, so a retry
    // cannot disburse twice.
    if (method == 'POST' &&
        path.startsWith('/loans/') &&
        path.endsWith('/agreement')) {
      try {
        final user = _requireBorrower();
        final loan = _ownedLoan(path.split('/')[2], user.id);
        if (loan.agreement != null) return _json(200, loan.toJson());

        final signedBy = (body['signedBy'] as String? ?? '').trim();
        if (signedBy.isEmpty) {
          throw const AppFailure(
            'validation_error',
            'Type your full name to sign the agreement.',
          );
        }

        if (loan.status != LoanStatus.funded ||
            loan.fundedPaisa < loan.amountPaisa) {
          throw const AppFailure(
            'invalid_transition',
            'Lenders must fully fund this loan before it can be signed.',
          );
        }
        LoanTransitions.check(loan.status, LoanStatus.active);
        final escrow = LedgerAccount.loanEscrow(loan.id);
        if (_db.balanceFor(escrow) < loan.amountPaisa) {
          throw const AppFailure(
            'insufficient_balance',
            'Escrow has not been funded yet. Try again once lenders have paid.',
          );
        }

        final now = DemoClock.instance.now;
        final journalId = 'txn-disburse-${loan.id}';
        final wallet = LedgerAccount.userWallet(user.id);
        final receipt = await _db.postJournal(
          journalId: journalId,
          paymentIntentId: 'pi-disburse-${loan.id}',
          idempotencyKey: 'disburse-${loan.id}',
          kind: JournalKind.disburse,
          intentKind: PaymentIntentKind.topup,
          userId: user.id,
          referenceId: loan.id,
          amountPaisa: loan.amountPaisa,
          entries: [
            LedgerEntry(
              id: '$journalId-1',
              journalId: journalId,
              accountId: escrow,
              amountPaisa: -loan.amountPaisa,
            ),
            LedgerEntry(
              id: '$journalId-2',
              journalId: journalId,
              accountId: wallet,
              amountPaisa: loan.amountPaisa,
            ),
          ],
          now: now,
        );

        final schedule = Money.schedule(
          principalPaisa: loan.amountPaisa,
          rateBps: loan.rateBps,
          tenorMonths: loan.tenorMonths,
          startDate: now,
        );
        final instalments = schedule
            .map(
              (item) => Instalment(
                id: '${loan.id}-inst-${item.number}',
                loanId: loan.id,
                number: item.number,
                dueDate: item.dueDate,
                principalPaisa: item.principalPaisa,
                interestPaisa: item.interestPaisa,
              ),
            )
            .toList(growable: false);

        final terms = LoanTerms.text(
          amountPaisa: loan.amountPaisa,
          rateBps: loan.rateBps,
          tenorMonths: loan.tenorMonths,
          purpose: loan.purpose,
        );
        final updated = loan.copyWith(
          status: LoanStatus.active,
          fundedPaisa: loan.amountPaisa,
          agreement: Agreement(
            id: 'agr-${loan.id}',
            loanId: loan.id,
            termsVersion: LoanTerms.version,
            termsHash: LoanTerms.hash(terms),
            signedBy: signedBy,
            signedAt: now,
            disbursementJournalId: receipt.journalId,
          ),
          instalments: instalments,
        );
        await _db.setLoan(updated);
        await _notifications.notify(
          userId: user.id,
          type: NotificationType.paymentReceived,
          title: 'Loan disbursed',
          body: 'Your ${loan.purpose} loan was disbursed. '
              'Repayments start with instalment 1.',
          id: 'notif-disbursed-${loan.id}',
          referenceId: loan.id,
          route: '/borrower/repay/${loan.id}',
          now: now,
        );
        return _json(200, updated.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    // Borrower repayment: one exact instalment, split across active stakes.
    if (method == 'POST' &&
        path.startsWith('/loans/') &&
        path.endsWith('/repay')) {
      try {
        final user = _requireBorrower();
        final loanId = path.split('/')[2];
        final number = (body['instalmentNumber'] as num?)?.toInt() ?? 0;
        final provider = (body['provider'] as String?)?.trim().isNotEmpty == true
            ? body['provider'] as String
            : 'esewa';
        final key = (body['idempotencyKey'] as String?)?.trim().isNotEmpty ==
                    true
            ? body['idempotencyKey'] as String
            : options.headers['Idempotency-Key'] as String? ??
                const Uuid().v4();
        // The amount comes from the stored schedule, never from the client.
        final loanForRepayment = _ownedLoan(loanId, user.id);
        final instalment = loanForRepayment.instalments
            .where((item) => item.number == number)
            .toList();
        if (instalment.isEmpty) {
          throw const AppFailure(
            'not_found',
            'We could not find that instalment.',
          );
        }
        final outcome = await _repaymentService.pay(
          loanId: loanId,
          borrowerId: user.id,
          instalmentNumber: number,
          amountPaisa: instalment.first.totalPaisa,
          provider: provider,
          idempotencyKey: key,
        );
        return _json(200, outcome.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'GET' && path.startsWith('/loans/')) {
      try {
        final user = _requireBorrower();
        return _json(200, _ownedLoan(path.split('/').last, user.id).toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    // Append-only money movement. The idempotency key lives in the journal and
    // receipt, so a replay returns the original receipt instead of a new entry.
    if (method == 'POST' && path == '/wallet/journals') {
      final kind = _parseJournalKind(body['kind']);
      final intentKind = _parseIntentKind(body['intentKind']);
      if (kind == null || intentKind == null) {
        return _json(422, {
          'error': 'validation_error',
          'message': 'Choose a valid money movement type.',
        });
      }
      try {
        final receipt = await _db.postJournal(
          journalId: body['journalId'] as String? ?? '',
          paymentIntentId: body['paymentIntentId'] as String? ?? '',
          idempotencyKey: body['idempotencyKey'] as String? ?? '',
          kind: kind,
          intentKind: intentKind,
          userId: body['userId'] as String? ?? '',
          referenceId: body['referenceId'] as String? ?? '',
          amountPaisa: (body['amountPaisa'] as num?)?.toInt() ?? 0,
          entries: _parseEntries(body['entries']),
          reversalOfId: body['reversalOfId'] as String?,
        );
        return _json(200, receipt.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'GET' && path.startsWith('/wallet/journals/')) {
      final journal = _db.journal(path.split('/').last);
      if (journal == null) {
        return _json(404, {
          'error': 'not_found',
          'message': 'We could not find that transaction.',
        });
      }
      return _json(200, journal.toJson());
    }

    if (method == 'POST' &&
        path.startsWith('/wallet/journals/') &&
        path.endsWith('/reverse')) {
      final original = _db.journal(path.split('/')[3]);
      if (original == null) {
        return _json(404, {
          'error': 'not_found',
          'message': 'We could not find that transaction.',
        });
      }
      try {
        final receipt = await _db.postJournal(
          journalId: body['journalId'] as String? ?? '',
          paymentIntentId: body['paymentIntentId'] as String? ?? '',
          idempotencyKey: body['idempotencyKey'] as String? ?? '',
          kind: JournalKind.reversal,
          intentKind: _parseIntentKind(body['intentKind']) ??
              (original.amountFor(
                      LedgerAccount.userWallet(original.referenceId)) >=
                  0
                  ? PaymentIntentKind.withdrawal
                  : PaymentIntentKind.topup),
          userId: body['userId'] as String? ?? '',
          referenceId: original.id,
          amountPaisa: (body['amountPaisa'] as num?)?.toInt() ?? 0,
          entries: original.entries
              .map(
                (entry) => LedgerEntry(
                  id: '${entry.id}-rev',
                  journalId: body['journalId'] as String? ?? '',
                  accountId: entry.accountId,
                  amountPaisa: -entry.amountPaisa,
                ),
              )
              .toList(),
          reversalOfId: original.id,
        );
        return _json(200, receipt.toJson());
      } on AppFailure catch (failure) {
        return _failure(failure);
      }
    }

    if (method == 'POST' && path == '/notifications/read-all') {
      final user = _db.currentUser;
      if (user == null) {
        return _json(401, {
          'error': 'unauthorized',
          'message': 'Please sign in again.',
        });
      }
      final changed = await _notifications.markAllRead(user.id);
      return _json(200, {'changed': changed});
    }

    if (method == 'POST' &&
        path.startsWith('/notifications/') &&
        path.endsWith('/read')) {
      final user = _db.currentUser;
      if (user == null) {
        return _json(401, {
          'error': 'unauthorized',
          'message': 'Please sign in again.',
        });
      }
      final id = path.split('/')[2];
      final notification = _db.notification(id);
      if (notification == null || notification.userId != user.id) {
        return _json(404, {
          'error': 'not_found',
          'message': 'We could not find that notification.',
        });
      }
      final changed = await _notifications.markRead(id);
      return _json(200, {'changed': changed});
    }

    switch ((method, path)) {
      case ('GET', '/health'):
        return _json(200, {'status': 'ok', 'database': 'mock'});

      case ('POST', '/auth/session'):
        final existing = _db.currentUser;
        final user = existing ??
            AppUser(
              id: 'demo-user',
              phone: body['phone'] as String? ?? '+9779800000000',
            );
        await _db.setUser(user);
        return _json(200, {'user': user.toJson(), 'isNew': existing == null});

      case ('GET', '/me'):
        final user = _db.currentUser;
        if (user == null) {
          return _json(401, {
            'error': 'unauthorized',
            'message': 'Please sign in again.',
          });
        }
        return _json(200, {'user': user.toJson()});

      case ('PATCH', '/me'):
        final user = _db.currentUser;
        if (user == null) {
          return _json(401, {
            'error': 'unauthorized',
            'message': 'Please sign in again.',
          });
        }
        final updated = user.copyWith(
          name: body['name'] as String?,
          email: body['email'] as String?,
          role: _parseRole(body['role']),
        );
        await _db.setUser(updated);
        return _json(200, {'user': updated.toJson()});

      case ('POST', '/me/devices'):
        return _json(200, {'registered': true});

      case ('GET', '/me/kyc'):
        final profile = _db.kycProfile ?? KycProfile.initial();
        final user = _db.currentUser;
        if (user != null && user.kycState != profile.overallState) {
          await _db.setKyc(profile);
        }
        return _json(200, profile.toJson());

      case ('GET', '/loans'):
        return _json(200, {'items': <Object>[]});

      case ('GET', '/wallet'):
        final user = _db.currentUser;
        if (user == null) {
          return _json(401, {
            'error': 'unauthorized',
            'message': 'Please sign in again.',
          });
        }
        final accountId = LedgerAccount.userWallet(user.id);
        final transactions = _db
            .journalsFor(accountId)
            .reversed
            .map(
              (journal) => WalletTransaction.fromJournal(journal, accountId)
                  .toJson(),
            )
            .toList();
        return _json(200, <String, dynamic>{
          'accountId': accountId,
          'balancePaisa': _db.balanceFor(accountId),
          'currency': 'NPR',
          'transactions': transactions,
        });

      case ('GET', '/notifications'):
        final user = _db.currentUser;
        if (user == null) {
          return _json(401, {
            'error': 'unauthorized',
            'message': 'Please sign in again.',
          });
        }
        final items = _db.notificationsFor(user.id);
        return _json(200, {
          'items': items.map((item) => item.toJson()).toList(),
          'unreadCount': items.where((item) => item.isUnread).length,
        });

      default:
        return _json(404, {
          'error': 'not_found',
          'message': 'No mock route for $method $path',
        });
    }
  }

  @override
  void close({bool force = false}) {}

  AppUser _requireSignedIn() {
    final user = _db.currentUser;
    if (user == null) {
      throw const AppFailure('unauthorized', 'Please sign in again.');
    }
    return user;
  }

  Future<void> _notifyKycIfVerified(KycProfile profile) async {
    final user = _db.currentUser;
    if (user == null || profile.overallState != KycStatus.verified) return;
    await _notifications.notify(
      userId: user.id,
      type: NotificationType.kycApproved,
      title: 'Verification complete',
      body: 'Your identity is verified. You can now borrow or lend.',
      id: 'notif-kycApproved-${user.id}',
      referenceId: user.id,
      route: user.role == UserRole.borrower
          ? '/borrower/home'
          : '/lender/home',
    );
  }

  AppUser _requireBorrower() {
    final user = _requireSignedIn();
    if (user.role != UserRole.borrower) {
      throw const AppFailure(
        'role_required',
        'Only a borrower account can borrow and repay.',
      );
    }
    if (!user.isVerified) {
      throw const AppFailure(
        'kyc_required',
        'Complete verification before borrowing or repaying.',
      );
    }
    return user;
  }

  AppUser _requireLender() {
    final user = _db.currentUser;
    if (user == null) {
      throw const AppFailure('unauthorized', 'Please sign in again.');
    }
    if (user.role != UserRole.lender) {
      throw const AppFailure(
        'role_required',
        'Only a lender account can fund loans.',
      );
    }
    if (!user.isVerified) {
      throw const AppFailure(
        'kyc_required',
        'Complete verification before funding loans.',
      );
    }
    return user;
  }

  Loan _ownedLoan(String id, String borrowerId) {
    final loan = _db.loan(id);
    if (loan == null || loan.borrowerId != borrowerId) {
      throw const AppFailure(
        'not_found',
        'We could not find that loan application.',
      );
    }
    return loan;
  }

  UserRole? _parseRole(Object? value) {
    if (value == null) return null;
    for (final role in UserRole.values) {
      if (role.name == value) return role;
    }
    return null;
  }

  KycStepKind? _parseStep(Object? value) {
    if (value == null) return null;
    for (final step in KycStepKind.values) {
      if (step.name == value) return step;
    }
    return null;
  }

  KycStatus? _parseStatus(Object? value) {
    if (value == null) return null;
    for (final status in KycStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }

  JournalKind? _parseJournalKind(Object? value) {
    if (value == null) return null;
    for (final kind in JournalKind.values) {
      if (kind.name == value) return kind;
    }
    return null;
  }

  PaymentIntentKind? _parseIntentKind(Object? value) {
    if (value == null) return null;
    for (final kind in PaymentIntentKind.values) {
      if (kind.name == value) return kind;
    }
    return null;
  }

  List<LedgerEntry> _parseEntries(Object? value) {
    if (value is! List) return const <LedgerEntry>[];
    return value
        .whereType<Map>()
        .map(
          (item) => LedgerEntry(
            id: item['id'] as String? ?? '',
            journalId: item['journalId'] as String? ?? '',
            accountId: item['accountId'] as String? ?? '',
            amountPaisa: (item['amountPaisa'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
  }

  Map<String, String>? _stringMap(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item.toString()));
  }

  ResponseBody _failure(AppFailure failure) => _json(
        failure.code == 'validation_error' ? 422 : 409,
        <String, dynamic>{
          'error': failure.code,
          'message': failure.message,
        },
      );

  ResponseBody _json(int status, Object payload) => ResponseBody.fromString(
        jsonEncode(payload),
        status,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        },
      );
}
