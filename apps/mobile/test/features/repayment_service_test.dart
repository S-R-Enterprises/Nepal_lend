import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/features/repayments/data/repayment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RepaymentService service;
  const loanId = 'loan-repay';
  const borrowerId = 'borrower-1';
  const lenderA = 'lender-a';
  const lenderB = 'lender-b';
  const amount = 300000; // NPR 3,000

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
    DemoClock.instance.reset();
    addTearDown(() => DemoClock.instance.reset());
    service = RepaymentService(MockDb.instance);
  });

  Loan seedLoan({
    LoanStatus status = LoanStatus.active,
    DateTime? startDate,
    int lenderAStake = 111111,
    int lenderBStake = 188889,
  }) {
    final start = startDate ?? DateTime(2026, 1, 1);
    final schedule = Money.schedule(
      principalPaisa: amount,
      rateBps: 1200,
      tenorMonths: 3,
      startDate: start,
    );
    final loan = Loan(
      id: loanId,
      borrowerId: borrowerId,
      purpose: 'Business inventory',
      amountPaisa: amount,
      tenorMonths: 3,
      rateBps: 1200,
      status: status,
      fundedPaisa: amount,
      agreement: Agreement(
        id: 'agr-$loanId',
        loanId: loanId,
        termsVersion: 'v1',
        termsHash: 'hash',
        signedBy: 'Test Borrower',
        signedAt: start,
        disbursementJournalId: 'txn-disburse-$loanId',
      ),
      instalments: schedule
          .map(
            (item) => Instalment(
              id: '$loanId-inst-${item.number}',
              loanId: loanId,
              number: item.number,
              dueDate: item.dueDate,
              principalPaisa: item.principalPaisa,
              interestPaisa: item.interestPaisa,
            ),
          )
          .toList(growable: false),
    );
    MockDb.instance.loans[loanId] = loan;
    MockDb.instance.stakes['stake-a'] = Stake(
      id: 'stake-a',
      loanId: loanId,
      lenderId: lenderA,
      amountPaisa: lenderAStake,
      idempotencyKey: 'fund-a',
      fundingJournalId: 'txn-fund-a',
      createdAt: start,
    );
    MockDb.instance.stakes['stake-b'] = Stake(
      id: 'stake-b',
      loanId: loanId,
      lenderId: lenderB,
      amountPaisa: lenderBStake,
      idempotencyKey: 'fund-b',
      fundingJournalId: 'txn-fund-b',
      createdAt: start.add(const Duration(seconds: 1)),
    );
    return loan;
  }

  Future<void> topUpBorrower(int paisa) async {
    const journalId = 'txn-test-repay-topup';
    await MockDb.instance.postJournal(
      journalId: journalId,
      paymentIntentId: 'pi-test-repay-topup',
      idempotencyKey: 'test-repay-topup',
      kind: JournalKind.topup,
      intentKind: PaymentIntentKind.topup,
      userId: borrowerId,
      referenceId: 'demo',
      amountPaisa: paisa,
      entries: [
        LedgerEntry(
          id: '$journalId-1',
          journalId: journalId,
          accountId: LedgerAccount.externalCash,
          amountPaisa: -paisa,
        ),
        LedgerEntry(
          id: '$journalId-2',
          journalId: journalId,
          accountId: LedgerAccount.userWallet(borrowerId),
          amountPaisa: paisa,
        ),
      ],
    );
  }

  test('awkward stake ratios split exactly and the fee is removed from interest',
      () async {
    final loan = seedLoan();
    await topUpBorrower(amount * 2);
    final first = loan.instalments.first;
    final fee = Money.feeForInterest(first.interestPaisa);

    final outcome = await service.pay(
      loanId: loanId,
      borrowerId: borrowerId,
      instalmentNumber: first.number,
      amountPaisa: first.totalPaisa,
      provider: 'khalti',
      idempotencyKey: 'repay-first',
      now: DateTime(2026, 2, 1),
    );

    final journal = MockDb.instance.journal(outcome.receipt.journalId)!;
    expect(journal.kind, JournalKind.repayment);
    expect(journal.sumPaisa, 0);
    expect(outcome.feePaisa, fee);
    expect(MockDb.instance.balanceFor(LedgerAccount.platformFee), fee);

    final lenderCredits = journal.entries
        .where(
          (entry) =>
              LedgerAccount.isUserWallet(entry.accountId) &&
              entry.accountId != LedgerAccount.userWallet(borrowerId),
        )
        .fold<int>(0, (sum, entry) => sum + entry.amountPaisa);
    expect(lenderCredits, first.totalPaisa - fee);
    expect(
      MockDb.instance.balanceFor(LedgerAccount.userWallet(borrowerId)),
      amount * 2 - first.totalPaisa,
    );

    final stakes = MockDb.instance.stakesForLoan(loanId)
      ..sort((a, b) => a.id.compareTo(b.id));
    expect(
      stakes.fold<int>(0, (sum, stake) => sum + stake.principalRepaidPaisa),
      first.principalPaisa,
    );
    expect(
      stakes.fold<int>(0, (sum, stake) => sum + stake.interestRepaidPaisa),
      first.interestPaisa,
    );
    expect(
      stakes.fold<int>(0, (sum, stake) => sum + stake.feePaidPaisa),
      fee,
    );
    expect(
      stakes.fold<int>(0, (sum, stake) => sum + stake.netRepaidPaisa),
      first.totalPaisa - fee,
    );
    expect(outcome.instalment.isPaid, isTrue);
    expect((await service.reconcile()).isClean, isTrue);
    expect(
      MockDb.instance.notificationsFor(borrowerId)
          .where((item) => item.type == NotificationType.paymentReceived),
      isNotEmpty,
    );
  });

  test('replaying one repayment key never posts a second journal', () async {
    final loan = seedLoan();
    await topUpBorrower(amount * 2);
    final first = loan.instalments.first;

    final original = await service.pay(
      loanId: loanId,
      borrowerId: borrowerId,
      instalmentNumber: first.number,
      amountPaisa: first.totalPaisa,
      provider: 'esewa',
      idempotencyKey: 'repay-once',
    );
    final replay = await service.pay(
      loanId: loanId,
      borrowerId: borrowerId,
      instalmentNumber: first.number,
      amountPaisa: first.totalPaisa,
      provider: 'esewa',
      idempotencyKey: 'repay-once',
    );

    expect(replay.receipt.journalId, original.receipt.journalId);
    expect(replay.receipt.replayed, isTrue);
    expect(
      MockDb.instance.journals
          .where((item) => item.kind == JournalKind.repayment),
      hasLength(1),
    );
    expect(MockDb.instance.loan(loanId)!.paidInstalmentCount, 1);
  });

  test('late repayments clear overdue and the last instalment closes the loan',
      () async {
    final loan = seedLoan(
      status: LoanStatus.overdue,
      startDate: DateTime(2025, 11, 1),
    );
    await topUpBorrower(amount * 2);
    final now = DateTime(2025, 12, 5);

    for (var i = 1; i <= 3; i++) {
      final instalment = loan.instalments.firstWhere((item) => item.number == i);
      final outcome = await service.pay(
        loanId: loanId,
        borrowerId: borrowerId,
        instalmentNumber: i,
        amountPaisa: instalment.totalPaisa,
        provider: 'esewa',
        idempotencyKey: 'repay-$i',
        now: now.add(Duration(days: i)),
      );
      final updated = MockDb.instance.loan(loanId)!;
      if (i < 3) {
        expect(updated.status, LoanStatus.active);
      } else {
        expect(updated.status, LoanStatus.repaid);
        expect(outcome.loan.isFullyRepaid, isTrue);
      }
    }

    final result = await service.reconcile();
    expect(result.isClean, isTrue);
    expect(
      MockDb.instance.notificationsFor(borrowerId)
          .where((item) => item.title == 'Loan fully repaid'),
      hasLength(1),
    );
  });

  test('skipping instalments, wrong amounts and overdrafts are rejected',
      () async {
    final loan = seedLoan();
    final first = loan.instalments.first;

    await expectLater(
      service.pay(
        loanId: loanId,
        borrowerId: borrowerId,
        instalmentNumber: 2,
        amountPaisa: first.totalPaisa,
        provider: 'esewa',
        idempotencyKey: 'key-skip',
      ),
      throwsA(
        isA<AppFailure>().having((error) => error.code, 'code', 'invalid_transition'),
      ),
    );
    await expectLater(
      service.pay(
        loanId: loanId,
        borrowerId: borrowerId,
        instalmentNumber: 1,
        amountPaisa: first.totalPaisa + 1,
        provider: 'esewa',
        idempotencyKey: 'key-wrong-amount',
      ),
      throwsA(
        isA<AppFailure>().having((error) => error.code, 'code', 'invalid_amount'),
      ),
    );
    await expectLater(
      service.pay(
        loanId: loanId,
        borrowerId: borrowerId,
        instalmentNumber: 1,
        amountPaisa: first.totalPaisa,
        provider: 'esewa',
        idempotencyKey: 'key-broke',
      ),
      throwsA(
        isA<AppFailure>()
            .having((error) => error.code, 'code', 'insufficient_balance'),
      ),
    );
  });

  test('mock reminder and overdue jobs create the right notifications',
      () async {
    final now = DateTime(2026, 1, 10);
    // The first instalment is due one month after the start date, so a
    // 2025-12-13 start puts it exactly three days after `now`.
    seedLoan(startDate: DateTime(2025, 12, 13));

    final sent = await service.sendReminders(now: now);
    expect(sent, 1);
    expect(
      MockDb.instance.notificationsFor(borrowerId)
          .where((item) => item.title == 'Payment in 3 days'),
      hasLength(1),
    );

    seedLoan(status: LoanStatus.active, startDate: DateTime(2025, 11, 1));
    final changed = await service.markOverdue(now: now);
    expect(changed, 1);
    expect(MockDb.instance.loan(loanId)!.status, LoanStatus.overdue);
    expect(
      MockDb.instance.notificationsFor(borrowerId)
          .where((item) => item.title == 'Payment overdue'),
      isNotEmpty,
    );
  });

  test('a three-month loan reconciles while the demo clock is fast-forwarded',
      () async {
    final start = DemoClock.instance.now;
    final loan = seedLoan(startDate: start);
    await topUpBorrower(amount * 2);

    for (var number = 1; number <= 3; number++) {
      DemoClock.instance.advance(const Duration(days: 35));
      final instalment = loan.instalments.firstWhere(
        (item) => item.number == number,
      );
      if (number == 1) {
        expect(await service.markOverdue(now: DemoClock.instance.now), 1);
        expect(MockDb.instance.loan(loanId)!.status, LoanStatus.overdue);
      }
      final paid = await service.pay(
        loanId: loanId,
        borrowerId: borrowerId,
        instalmentNumber: number,
        amountPaisa: instalment.totalPaisa,
        provider: 'esewa',
        idempotencyKey: 'clock-repay-$number',
        now: DemoClock.instance.now,
      );
      expect(paid.instalment.isPaid, isTrue);
    }

    final updated = MockDb.instance.loan(loanId)!;
    expect(updated.status, LoanStatus.repaid);
    expect(updated.isFullyRepaid, isTrue);

    final result = await service.reconcile();
    expect(result.isClean, isTrue);
    expect(result.journalsChecked, greaterThanOrEqualTo(3));
    expect(
      MockDb.instance.notificationsFor(borrowerId)
          .where((item) => item.title == 'Payment overdue'),
      hasLength(1),
    );
    expect(
      MockDb.instance.notificationsFor(borrowerId)
          .where((item) => item.title == 'Loan fully repaid'),
      hasLength(1),
    );
  });
}
