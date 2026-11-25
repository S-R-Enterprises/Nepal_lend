import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/auth/presentation/onboarding_screen.dart';
import 'package:nepal_lend/features/lending/presentation/fund_loan_screen.dart';
import 'package:nepal_lend/features/lending/presentation/lender_browse_screen.dart';
import 'package:nepal_lend/features/lending/presentation/lender_home_screen.dart';
import 'package:nepal_lend/features/lending/presentation/lender_portfolio_screen.dart';
import 'package:nepal_lend/features/lending/presentation/loan_details_screen.dart';
import 'package:nepal_lend/features/lending/presentation/stake_detail_screen.dart';
import 'package:nepal_lend/features/loans/presentation/borrower_home_screen.dart';
import 'package:nepal_lend/features/loans/presentation/loan_agreement_screen.dart';
import 'package:nepal_lend/features/loans/presentation/risk_review_screen.dart';
import 'package:nepal_lend/features/wallet/data/wallet_controller.dart';
import 'package:nepal_lend/features/wallet/presentation/transaction_receipt_screen.dart';
import 'package:nepal_lend/features/wallet/presentation/wallet_action_screen.dart';
import 'package:nepal_lend/features/wallet/presentation/wallet_screen.dart';
import 'package:nepal_lend/l10n/app_localizations_en.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _l10n = AppLocalizationsEn();

void main() {
  late ProviderContainer container;
  late String userId;

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
    final auth = container.read(authProvider.notifier);
    await auth.demoSignIn();
    await MockDb.instance.setKyc(KycProfile.initial().approveAll());
    await auth.refresh();
    userId = container.read(authProvider).user!.id;
  });

  tearDown(() => container.dispose());

  Future<void> setRole(UserRole role) async {
    await container.read(authProvider.notifier).setRole(role);
    await container.read(authProvider.notifier).refresh();
  }

  Future<void> seedBorrowerLoan() => MockDb.instance.setLoan(
        Loan(
          id: 'loan-screen-1',
          borrowerId: userId,
          purpose: 'Business inventory',
          amountPaisa: 20000000,
          tenorMonths: 12,
          rateBps: 1200,
          status: LoanStatus.open,
          borrowerName: 'Demo Borrower',
          riskGrade: 'A',
          riskBand: RiskBand.low,
          assessment: RiskAssessment(
            score: 88,
            grade: 'A',
            band: RiskBand.low,
            rateBps: 1200,
            factors: const [
              RiskFactor(
                name: 'Affordability',
                direction: RiskDirection.positive,
                note: 'Income covers the instalment.',
              ),
            ],
          ),
          fundingDeadline: DateTime(2030, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
      );

  Future<void> seedLenderLoan() => MockDb.instance.setLoan(
        Loan(
          id: 'lender-loan-1',
          borrowerId: 'borrower-1',
          purpose: 'Business inventory',
          amountPaisa: 20000000,
          tenorMonths: 12,
          rateBps: 1200,
          status: LoanStatus.open,
          borrowerName: 'Test Borrower',
          riskGrade: 'A',
          riskBand: RiskBand.low,
          fundingDeadline: DateTime(2030, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
      );

  Future<void> seedStake() => MockDb.instance.setStake(
        Stake(
          id: 'stake-screen-1',
          loanId: 'lender-loan-1',
          lenderId: userId,
          amountPaisa: 10000000,
          idempotencyKey: 'screen-suite-stake',
          fundingJournalId: 'journal-screen-1',
          createdAt: DateTime(2026, 1, 2),
        ),
      );

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen,
    Finder ready,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: screen),
      ),
    );
    for (var i = 0; i < 100; i++) {
      if (tester.any(ready)) break;
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(ready, findsWidgets, reason: 'Screen did not finish loading');
    // Flush the zero-delay Dio timers started by the notification badge.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull);
  }

  testWidgets('onboarding screen renders', (tester) async {
    await pumpScreen(
      tester,
      const OnboardingScreen(),
      find.text(_l10n.onboardingSkip),
    );
  });

  testWidgets('borrower home screen renders', (tester) async {
    await seedBorrowerLoan();
    await pumpScreen(
      tester,
      const BorrowerHomeScreen(),
      find.text(_l10n.borrowerHomeTitle),
    );
  });

  testWidgets('risk review screen renders', (tester) async {
    await seedBorrowerLoan();
    await pumpScreen(
      tester,
      const RiskReviewScreen(loanId: 'loan-screen-1'),
      find.text(_l10n.riskReviewTitle),
    );
  });

  testWidgets('loan agreement screen renders', (tester) async {
    await seedBorrowerLoan();
    await pumpScreen(
      tester,
      const LoanAgreementScreen(loanId: 'loan-screen-1'),
      find.text(_l10n.loanAgreementTitle),
    );
  });

  testWidgets('wallet screen renders with balance', (tester) async {
    await container.read(walletControllerProvider.notifier).topUp(50000000);
    await pumpScreen(
      tester,
      const WalletScreen(),
      find.text(_l10n.walletTitle),
    );
  });

  testWidgets('wallet action screens render', (tester) async {
    await pumpScreen(
      tester,
      const WalletActionScreen(mode: WalletActionMode.topup),
      find.text(_l10n.topUpWalletTitle),
    );
    await pumpScreen(
      tester,
      const WalletActionScreen(mode: WalletActionMode.withdrawal),
      find.text(_l10n.withdrawToBankTitle),
    );
  });

  testWidgets('transaction receipt screen renders', (tester) async {
    final receipt =
        await container.read(walletControllerProvider.notifier).topUp(50000000);
    await pumpScreen(
      tester,
      TransactionReceiptScreen(journalId: receipt!.journalId),
      find.text(_l10n.transactionReceiptTitle),
    );
  });

  testWidgets('lender home screen renders', (tester) async {
    await setRole(UserRole.lender);
    await seedLenderLoan();
    await pumpScreen(
      tester,
      const LenderHomeScreen(),
      find.text(_l10n.lenderHomeTitle),
    );
  });

  testWidgets('lender browse screen renders', (tester) async {
    await setRole(UserRole.lender);
    await seedLenderLoan();
    await pumpScreen(
      tester,
      const LenderBrowseScreen(),
      find.text(_l10n.openLoansTitle),
    );
  });

  testWidgets('lender portfolio screen renders', (tester) async {
    await setRole(UserRole.lender);
    await seedLenderLoan();
    await seedStake();
    await pumpScreen(
      tester,
      const LenderPortfolioScreen(),
      find.text(_l10n.portfolioTitle),
    );
  });

  testWidgets('lender loan details screen renders', (tester) async {
    await setRole(UserRole.lender);
    await seedLenderLoan();
    await pumpScreen(
      tester,
      const LoanDetailsScreen(loanId: 'lender-loan-1'),
      find.text(_l10n.loanDetailsTitle),
    );
  });

  testWidgets('fund loan screen renders', (tester) async {
    await setRole(UserRole.lender);
    await seedLenderLoan();
    await container.read(walletControllerProvider.notifier).topUp(50000000);
    await pumpScreen(
      tester,
      const FundLoanScreen(loanId: 'lender-loan-1'),
      find.text(_l10n.fundLoanTitle),
    );
  });

  testWidgets('stake details screen renders', (tester) async {
    await setRole(UserRole.lender);
    await seedLenderLoan();
    await seedStake();
    await pumpScreen(
      tester,
      const StakeDetailScreen(stakeId: 'stake-screen-1'),
      find.text(_l10n.stakeDetailsTitle),
    );
  });
}
