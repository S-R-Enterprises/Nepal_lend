import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/data/models/ledger.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/data/models/payment_intent.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/lending/data/funding_service.dart';
import 'package:nepal_lend/features/loans/data/loan_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

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

  Future<void> signIn({
    required UserRole role,
    bool verified = true,
  }) async {
    await container.read(authProvider.notifier).demoSignIn();
    await container.read(authProvider.notifier).setRole(role);
    if (verified) {
      await MockDb.instance.setKyc(KycProfile.initial().approveAll());
    }
    await container.read(authProvider.notifier).refresh();
  }

  Future<Loan?> request() =>
      container.read(loanControllerProvider.notifier).createApplication(
            purpose: 'Business inventory',
            amountPaisa: 20000000,
            tenorMonths: 12,
            monthlyIncomePaisa: 5000000,
          );

  Future<void> fundFully(Loan loan) async {
    const lenderId = 'lender-1';
    final topupId = 'txn-test-topup-$lenderId-${loan.id}';
    await MockDb.instance.postJournal(
      journalId: topupId,
      paymentIntentId: 'pi-test-topup-$lenderId-${loan.id}',
      idempotencyKey: 'test-topup-$lenderId-${loan.id}',
      kind: JournalKind.topup,
      intentKind: PaymentIntentKind.topup,
      userId: lenderId,
      referenceId: loan.id,
      amountPaisa: loan.amountPaisa,
      entries: [
        LedgerEntry(
          id: '$topupId-1',
          journalId: topupId,
          accountId: LedgerAccount.externalCash,
          amountPaisa: -loan.amountPaisa,
        ),
        LedgerEntry(
          id: '$topupId-2',
          journalId: topupId,
          accountId: LedgerAccount.userWallet(lenderId),
          amountPaisa: loan.amountPaisa,
        ),
      ],
    );
    await FundingService(MockDb.instance).fund(
      loanId: loan.id,
      lenderId: lenderId,
      amountPaisa: loan.amountPaisa,
      idempotencyKey: 'test-fund-${loan.id}',
    );
  }

  test('unverified users are blocked before any application is stored', () async {
    await signIn(role: UserRole.borrower, verified: false);

    final loan = await request();

    expect(loan, isNull);
    expect(
      container.read(loanControllerProvider).error,
      contains('verification'),
    );
    expect(MockDb.instance.loans, isEmpty);
  });

  test('lenders cannot request loans even when verified', () async {
    await signIn(role: UserRole.lender);

    final loan = await request();

    expect(loan, isNull);
    expect(
      container.read(loanControllerProvider).error,
      contains('borrower'),
    );
    expect(MockDb.instance.loans, isEmpty);
  });

  test('controller keeps one current loan through the full flow', () async {
    await signIn(role: UserRole.borrower);
    final controller = container.read(loanControllerProvider.notifier);

    final created = await request();
    expect(created, isNotNull);
    expect(container.read(loanControllerProvider).current?.id, created!.id);
    expect(container.read(loanControllerProvider).loans, hasLength(1));

    await fundFully(created);
    final signed = await controller.signAgreement(
      id: created.id,
      signedBy: 'Demo Borrower',
    );
    expect(signed?.status, LoanStatus.active);
    expect(signed?.instalments, hasLength(12));
    expect(
      container.read(loanControllerProvider).current?.status,
      LoanStatus.active,
    );
    expect(
      MockDb.instance.journal(signed!.agreement!.disbursementJournalId),
      isNotNull,
    );
  });
}
