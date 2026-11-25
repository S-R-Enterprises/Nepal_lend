import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/core/utils/money.dart';
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
  late LoanRepository repository;
  const userId = 'borrower-1';
  final wallet = LedgerAccount.userWallet(userId);

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await MockDb.instance.clear();
    await MockDb.instance.setUser(
      const AppUser(
        id: userId,
        phone: '+9779800000000',
        role: UserRole.borrower,
        kycState: KycStatus.verified,
      ),
    );
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
    repository = container.read(loanRepositoryProvider);
  });

  tearDown(() => container.dispose());

  Future<Loan> apply({
    int amount = 20000000,
    int tenor = 12,
    int income = 5000000,
    String purpose = 'Business inventory',
  }) =>
      repository.createApplication(
        purpose: purpose,
        amountPaisa: amount,
        tenorMonths: tenor,
        monthlyIncomePaisa: income,
      );

  /// Direct domain call so borrower-flow tests can reach `funded` without
  /// switching the single demo user to a lender account.
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

  test('application produces a grade, rate and review decision', () async {
    final loan = await apply();

    expect(loan.status, LoanStatus.open);
    expect(loan.riskGrade, 'A');
    expect(loan.rateBps, 1200);
    expect(loan.assessment?.modelVersion, 'v1');
    expect(loan.assessment?.factors, hasLength(5));
    expect(loan.fundingDeadline, isNotNull);
    expect(MockDb.instance.loan(loan.id), isNotNull);

    final mine = await repository.myLoans();
    expect(mine.single.id, loan.id);
    expect(await repository.loan(loan.id), isNotNull);
  });

  test('grade D / high-value applications wait for demo approval', () async {
    final loan = await apply(amount: 50000000, tenor: 60, income: 100000);
    expect(loan.status, LoanStatus.pendingReview);
    expect(loan.assessment?.requiresReview, isTrue);

    expect(
      () => repository.signAgreement(id: loan.id, signedBy: 'Demo Borrower'),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'invalid_transition',
        ),
      ),
    );

    final approved = await repository.approve(loan.id);
    expect(approved.status, LoanStatus.open);
    await fundFully(approved);
    final signed = await repository.signAgreement(
      id: loan.id,
      signedBy: 'Demo Borrower',
    );
    expect(signed.status, LoanStatus.active);
  });

  test('signing creates 12 instalments and a zero-sum escrow journal',
      () async {
    final loan = await apply();
    await fundFully(loan);
    final signed = await repository.signAgreement(
      id: loan.id,
      signedBy: 'Demo Borrower',
    );

    expect(signed.status, LoanStatus.active);
    expect(signed.agreement, isNotNull);
    expect(signed.agreement!.signedBy, 'Demo Borrower');
    expect(signed.agreement!.termsVersion, 'v1');
    expect(signed.agreement!.termsHash, isNotEmpty);
    expect(signed.instalments, hasLength(12));
    expect(
      signed.instalments.fold<int>(
        0,
        (sum, item) => sum + item.principalPaisa,
      ),
      20000000,
    );
    expect(
      signed.instalments.fold<int>(
        0,
        (sum, item) => sum + item.totalPaisa,
      ),
      greaterThan(20000000),
    );

    final journal = MockDb.instance.journal(
      signed.agreement!.disbursementJournalId,
    );
    expect(journal, isNotNull);
    expect(journal!.kind, JournalKind.disburse);
    expect(journal.sumPaisa, 0);
    expect(
      journal.amountFor(LedgerAccount.loanEscrow(loan.id)),
      -20000000,
    );
    expect(journal.amountFor(wallet), 20000000);
    expect(MockDb.instance.balanceFor(wallet), 20000000);
    expect(MockDb.instance.balanceFor(LedgerAccount.loanEscrow(loan.id)), 0);
  });

  test('re-signing an agreement never disburses twice', () async {
    final loan = await apply();
    await fundFully(loan);
    final first = await repository.signAgreement(
      id: loan.id,
      signedBy: 'Demo Borrower',
    );
    final replay = await repository.signAgreement(
      id: loan.id,
      signedBy: 'Someone Else',
    );

    expect(replay.agreement?.id, first.agreement?.id);
    expect(replay.agreement?.signedBy, 'Demo Borrower');
    expect(
      MockDb.instance.journals.where((item) => item.kind == JournalKind.disburse),
      hasLength(1),
    );
    expect(MockDb.instance.balanceFor(wallet), 20000000);
  });

  test('schedule uses the exact same EMI maths as the money module', () async {
    final loan = await apply();
    await fundFully(loan);
    final signed = await repository.signAgreement(
      id: loan.id,
      signedBy: 'Demo Borrower',
    );
    final expected = Money.schedule(
      principalPaisa: loan.amountPaisa,
      rateBps: loan.rateBps,
      tenorMonths: loan.tenorMonths,
    );

    expect(signed.instalments, hasLength(expected.length));
    for (var i = 0; i < expected.length; i++) {
      expect(signed.instalments[i].number, expected[i].number);
      expect(
        signed.instalments[i].principalPaisa,
        expected[i].principalPaisa,
      );
      expect(
        signed.instalments[i].interestPaisa,
        expected[i].interestPaisa,
      );
    }
  });

  test('invalid applications are rejected before a loan is stored', () async {
    expect(
      () => apply(amount: 999999),
      throwsA(isA<AppFailure>()),
    );
    expect(
      () => apply(tenor: 2),
      throwsA(isA<AppFailure>()),
    );
    expect(
      () => apply(income: 0),
      throwsA(isA<AppFailure>()),
    );
    expect(MockDb.instance.loans, isEmpty);
  });
}
