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
import 'package:nepal_lend/data/repositories/funding_repository.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/lending/data/lending_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late FundingRepository repository;
  const lenderId = 'lender-1';

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
    repository = container.read(fundingRepositoryProvider);
  });

  tearDown(() => container.dispose());

  Future<void> setUser({
    required String id,
    required UserRole role,
    KycStatus kyc = KycStatus.verified,
  }) =>
      MockDb.instance.setUser(
        AppUser(
          id: id,
          phone: '+9779800000000',
          role: role,
          kycState: kyc,
        ),
      );

  Future<void> seedLoan({
    required String id,
    int amount = 20000000,
    RiskBand band = RiskBand.low,
    int tenor = 12,
  }) =>
      MockDb.instance.setLoan(
        Loan(
          id: id,
          borrowerId: 'borrower-1',
          purpose: 'Business inventory',
          amountPaisa: amount,
          tenorMonths: tenor,
          rateBps: 1200,
          status: LoanStatus.open,
          borrowerName: 'Test Borrower',
          riskGrade: 'A',
          riskBand: band,
          fundingDeadline: DateTime(2030, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
      );

  Future<void> topUp(int amount) async {
    const journalId = 'txn-test-topup-$lenderId';
    await MockDb.instance.postJournal(
      journalId: journalId,
      paymentIntentId: 'pi-test-topup-$lenderId',
      idempotencyKey: 'test-topup-$lenderId',
      kind: JournalKind.topup,
      intentKind: PaymentIntentKind.topup,
      userId: lenderId,
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
          accountId: LedgerAccount.userWallet(lenderId),
          amountPaisa: amount,
        ),
      ],
    );
  }

  test('browse returns only open loans that match filters and sort', () async {
    await setUser(id: lenderId, role: UserRole.lender);
    await seedLoan(id: 'loan-small', amount: 1000000, band: RiskBand.low);
    await seedLoan(id: 'loan-big', amount: 40000000, band: RiskBand.high, tenor: 24);
    await seedLoan(id: 'loan-closed', amount: 20000000).then((_) async {
      final loan = MockDb.instance.loan('loan-closed')!;
      await MockDb.instance.setLoan(loan.copyWith(status: LoanStatus.funded));
    });

    final all = await repository.browseLoans();
    expect(all.map((loan) => loan.id), containsAll(['loan-big', 'loan-small']));
    expect(all.map((loan) => loan.id), isNot(contains('loan-closed')));

    final filtered = await repository.browseLoans(
      riskBand: RiskBand.low,
      minAmountPaisa: 500000,
      maxAmountPaisa: 2000000,
      maxTenorMonths: 12,
    );
    expect(filtered.map((loan) => loan.id), ['loan-small']);

    final byAmount = await repository.browseLoans(sort: 'amountDesc');
    expect(byAmount.first.id, 'loan-big');
  });

  test('fund and stake endpoints enforce lender role and KYC', () async {
    await seedLoan(id: 'loan-1');
    await topUp(20000000);

    await setUser(id: 'borrower-1', role: UserRole.borrower);
    await expectLater(
      repository.fund(
        loanId: 'loan-1',
        amountPaisa: 100000,
        idempotencyKey: 'wrong-role',
      ),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'role_required',
        ),
      ),
    );

    await setUser(
      id: lenderId,
      role: UserRole.lender,
      kyc: KycStatus.inReview,
    );
    await expectLater(
      repository.browseLoans(),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'kyc_required',
        ),
      ),
    );

    await setUser(id: lenderId, role: UserRole.lender);
    final stake = await repository.fund(
      loanId: 'loan-1',
      amountPaisa: 100000,
      idempotencyKey: 'good-key',
    );
    expect(stake.lenderId, lenderId);
    expect(stake.fundingJournalId, isNotEmpty);

    final detail = await repository.stake(stake.id);
    expect(detail.stake.id, stake.id);
    expect(detail.loan.id, 'loan-1');

    await setUser(id: 'lender-2', role: UserRole.lender);
    await expectLater(
      repository.stake(stake.id),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'not_found',
        ),
      ),
    );
  });

  test('lending controller blocks unverified and wrong-role funding', () async {
    await seedLoan(id: 'loan-1');
    await topUp(20000000);
    final auth = container.read(authProvider.notifier);
    await auth.demoSignIn();
    await auth.setRole(UserRole.lender);
    await container.read(authProvider.notifier).refresh();
    final controller = container.read(lendingControllerProvider.notifier);

    await controller.browse();
    expect(
      container.read(lendingControllerProvider).error,
      contains('verification'),
    );

    await setUser(
      id: 'borrower-1',
      role: UserRole.borrower,
      kyc: KycStatus.verified,
    );
    await auth.refresh();
    final wrongRole = await controller.fund(
      loanId: 'loan-1',
      amountPaisa: 100000,
      idempotencyKey: 'controller-wrong-role',
    );
    expect(wrongRole, isNull);
    expect(
      container.read(lendingControllerProvider).error,
      contains('lender'),
    );
    expect(MockDb.instance.stakes, isEmpty);
  });
}
