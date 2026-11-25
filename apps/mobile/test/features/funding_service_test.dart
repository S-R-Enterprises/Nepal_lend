import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/data/repositories/loan_repository.dart';
import 'package:nepal_lend/features/lending/data/funding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  const loanId = 'loan-1';
  const borrowerId = 'borrower-1';
  const escrow = 'loan_escrow:loan-1';

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
    container = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(
          const Env(
            environment: AppEnvironment.mock,
            apiBaseUrl: 'https://mock.local/api/v1',
          ),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> seedLoan({
    int amount = 20000000,
    DateTime? deadline,
  }) =>
      MockDb.instance.setLoan(
        Loan(
          id: loanId,
          borrowerId: borrowerId,
          purpose: 'Business inventory',
          amountPaisa: amount,
          tenorMonths: 12,
          rateBps: 1200,
          status: LoanStatus.open,
          borrowerName: 'Test Borrower',
          fundingDeadline: deadline ?? DateTime(2030, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
      );

  Future<void> topUp(
    String userId,
    int amount, {
    required String key,
  }) async {
    final journalId = 'txn-test-topup-$key';
    await MockDb.instance.postJournal(
      journalId: journalId,
      paymentIntentId: 'pi-test-topup-$key',
      idempotencyKey: 'test-topup-$key',
      kind: JournalKind.topup,
      intentKind: PaymentIntentKind.topup,
      userId: userId,
      referenceId: 'demo',
      amountPaisa: amount,
      entries: [
        LedgerEntry(
          id: '$journalId-1',
          journalId: journalId,
          accountId: LedgerAccount.externalCash,
          amountPaisa: -amount,
        ),
        LedgerEntry(
          id: '$journalId-2',
          journalId: journalId,
          accountId: LedgerAccount.userWallet(userId),
          amountPaisa: amount,
        ),
      ],
    );
  }

  int fundJournalCount() => MockDb.instance.journals
      .where((journal) => journal.kind == JournalKind.fund)
      .length;

  test('two lenders fill escrow and the borrower can then sign', () async {
    await seedLoan();
    await topUp('lender-a', 12000000, key: 'a');
    await topUp('lender-b', 8000000, key: 'b');
    final service = FundingService(MockDb.instance);

    final first = await service.fund(
      loanId: loanId,
      lenderId: 'lender-a',
      amountPaisa: 12000000,
      idempotencyKey: 'fund-a',
      now: DateTime(2026, 2, 1),
    );
    final second = await service.fund(
      loanId: loanId,
      lenderId: 'lender-b',
      amountPaisa: 8000000,
      idempotencyKey: 'fund-b',
      now: DateTime(2026, 2, 2),
    );

    expect(first.lenderId, 'lender-a');
    expect(second.lenderId, 'lender-b');
    expect(MockDb.instance.stakesForLoan(loanId), hasLength(2));
    expect(
      MockDb.instance.stakesForLoan(loanId).fold<int>(
            0,
            (sum, stake) => sum + stake.amountPaisa,
          ),
      20000000,
    );
    expect(MockDb.instance.balanceFor(escrow), 20000000);
    expect(MockDb.instance.loan(loanId)!.fundedPaisa, 20000000);
    expect(MockDb.instance.loan(loanId)!.status, LoanStatus.funded);

    await MockDb.instance.setUser(
      const AppUser(
        id: borrowerId,
        phone: '+9779800000000',
        role: UserRole.borrower,
        kycState: KycStatus.verified,
      ),
    );
    final signed = await container.read(loanRepositoryProvider).signAgreement(
          id: loanId,
          signedBy: 'Test Borrower',
        );

    expect(signed.status, LoanStatus.active);
    expect(signed.agreement, isNotNull);
    expect(MockDb.instance.balanceFor(escrow), 0);
    expect(signed.instalments, hasLength(12));
  });

  test('a stake cannot exceed the amount still needed', () async {
    await seedLoan();
    await topUp('lender-a', 20000000, key: 'a');
    final service = FundingService(MockDb.instance);
    await service.fund(
      loanId: loanId,
      lenderId: 'lender-a',
      amountPaisa: 12000000,
      idempotencyKey: 'fund-first',
    );

    await expectLater(
      service.fund(
        loanId: loanId,
        lenderId: 'lender-a',
        amountPaisa: 9000000,
        idempotencyKey: 'fund-too-much',
      ),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'exceeds_remaining',
        ),
      ),
    );

    expect(MockDb.instance.stakesForLoan(loanId), hasLength(1));
    expect(fundJournalCount(), 1);
    expect(MockDb.instance.balanceFor(escrow), 12000000);
    expect(MockDb.instance.loan(loanId)!.status, LoanStatus.open);
  });

  test('stakes below the minimum and overbalances are rejected', () async {
    await seedLoan();
    final service = FundingService(MockDb.instance);

    await expectLater(
      service.fund(
        loanId: loanId,
        lenderId: 'lender-a',
        amountPaisa: 99999,
        idempotencyKey: 'tiny',
      ),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'below_minimum',
        ),
      ),
    );
    await expectLater(
      service.fund(
        loanId: loanId,
        lenderId: 'lender-a',
        amountPaisa: 100000,
        idempotencyKey: 'empty-wallet',
      ),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'insufficient_balance',
        ),
      ),
    );

    expect(MockDb.instance.stakes, isEmpty);
    expect(fundJournalCount(), 0);
    expect(MockDb.instance.balanceFor(escrow), 0);
  });

  test('a replayed idempotency key returns the same stake once', () async {
    await seedLoan();
    await topUp('lender-a', 20000000, key: 'a');
    final service = FundingService(MockDb.instance);

    final first = await service.fund(
      loanId: loanId,
      lenderId: 'lender-a',
      amountPaisa: 10000000,
      idempotencyKey: 'same-key',
    );
    final replay = await service.fund(
      loanId: loanId,
      lenderId: 'lender-a',
      amountPaisa: 10000000,
      idempotencyKey: 'same-key',
    );

    expect(replay.id, first.id);
    expect(replay.fundingJournalId, first.fundingJournalId);
    expect(MockDb.instance.stakesForLoan(loanId), hasLength(1));
    expect(fundJournalCount(), 1);
    expect(MockDb.instance.balanceFor(escrow), 10000000);
  });

  test('ten parallel fund calls cannot overdraw or over-fund the escrow',
      () async {
    await seedLoan(amount: 20000000);
    await topUp('lender-a', 20000000, key: 'a');
    final service = FundingService(MockDb.instance);

    final results = await Future.wait(
      List.generate(
        10,
        (index) => service.fund(
          loanId: loanId,
          lenderId: 'lender-a',
          amountPaisa: 2000000,
          idempotencyKey: 'parallel-$index',
        ),
      ),
    );

    expect(results.map((stake) => stake.id).toSet(), hasLength(10));
    expect(fundJournalCount(), 10);
    expect(MockDb.instance.balanceFor(escrow), 20000000);
    expect(MockDb.instance.balanceFor(LedgerAccount.userWallet('lender-a')), 0);
    expect(MockDb.instance.loan(loanId)!.status, LoanStatus.funded);
    expect(MockDb.instance.loan(loanId)!.fundedPaisa, 20000000);
  });

  test('expiry reverses partial stakes back to lenders exactly once', () async {
    final deadline = DateTime(2026, 3, 1);
    await seedLoan(deadline: deadline);
    await topUp('lender-a', 20000000, key: 'a');
    final service = FundingService(MockDb.instance);
    await service.fund(
      loanId: loanId,
      lenderId: 'lender-a',
      amountPaisa: 10000000,
      idempotencyKey: 'fund-before-expiry',
      now: DateTime(2026, 2, 1),
    );

    final released = await service.expireLoan(
      loanId,
      now: deadline.add(const Duration(days: 1)),
    );

    expect(released, 1);
    expect(MockDb.instance.balanceFor(escrow), 0);
    expect(MockDb.instance.balanceFor(LedgerAccount.userWallet('lender-a')),
        20000000);
    final stake = MockDb.instance.stakesForLoan(loanId).single;
    expect(stake.status, 'returned');
    expect(stake.reversalJournalId, isNotEmpty);
    expect(MockDb.instance.loan(loanId)!.status, LoanStatus.expired);
    expect(MockDb.instance.loan(loanId)!.fundedPaisa, 0);

    final journalCount = MockDb.instance.journals.length;
    expect(
      await service.expireLoan(
        loanId,
        now: deadline.add(const Duration(days: 2)),
      ),
      0,
    );
    expect(MockDb.instance.journals, hasLength(journalCount));
  });
}
