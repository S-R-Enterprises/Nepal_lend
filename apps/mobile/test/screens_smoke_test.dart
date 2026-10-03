import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_lend/features/borrower/presentation/borrower_home_screen.dart';
import 'package:nepal_lend/features/borrower/presentation/loan_agreement_screen.dart';
import 'package:nepal_lend/features/borrower/presentation/repay_screen.dart';
import 'package:nepal_lend/features/borrower/presentation/request_loan_screen.dart';
import 'package:nepal_lend/features/borrower/presentation/risk_review_screen.dart';
import 'package:nepal_lend/features/lender/presentation/browse_loans_screen.dart';
import 'package:nepal_lend/features/lender/presentation/funding_success_screen.dart';
import 'package:nepal_lend/features/lender/presentation/lender_home_screen.dart';
import 'package:nepal_lend/features/lender/presentation/loan_details_screen.dart';
import 'package:nepal_lend/features/lender/presentation/loan_stake_detail_screen.dart';
import 'package:nepal_lend/features/lender/presentation/portfolio_screen.dart';
import 'package:nepal_lend/features/lender/presentation/transaction_detail_screen.dart';
import 'package:nepal_lend/features/lender/presentation/wallet_screen.dart';
import 'package:nepal_lend/features/kyc/presentation/kyc_screen.dart';
import 'package:nepal_lend/features/auth/presentation/login_screen.dart';
import 'package:nepal_lend/features/auth/presentation/onboarding_screen.dart';
import 'package:nepal_lend/features/auth/presentation/otp_screen.dart';
import 'package:nepal_lend/features/auth/presentation/registration_screen.dart';
import 'package:nepal_lend/features/auth/presentation/role_selection_screen.dart';
import 'package:nepal_lend/features/help/presentation/help_safety_screen.dart';
import 'package:nepal_lend/features/notifications/presentation/notifications_screen.dart';
import 'package:nepal_lend/features/profile/presentation/profile_screen.dart';
import 'package:nepal_lend/features/style_guide/presentation/style_guide_screen.dart';

import 'load_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  final screens = <String, Widget Function()>{
    'Onboarding': () => const OnboardingScreen(),
    'RoleSelection': () => const RoleSelectionScreen(),
    'Registration': () => const RegistrationScreen(),
    'OTP': () => const OTPScreen(),
    'Login': () => const LoginScreen(),
    'KYC': () => const KYCScreen(),
    'LenderHome': () => const LenderHomeScreen(),
    'BrowseLoans': () => const BrowseLoansScreen(),
    'LoanDetails': () => const LoanDetailsScreen(),
    'FundingSuccess': () => const FundingSuccessScreen(),
    'Portfolio': () => const PortfolioScreen(),
    'LoanStake': () => const LoanStakeDetailScreen(),
    'Wallet': () => const WalletScreen(),
    'Transaction': () => const TransactionDetailScreen(),
    'BorrowerHome': () => const BorrowerHomeScreen(),
    'RequestLoan': () => const RequestLoanScreen(),
    'RiskReview': () => const RiskReviewScreen(),
    'LoanAgreement': () => const LoanAgreementScreen(),
    'Repay': () => const RepayScreen(),
    'Notifications': () => const NotificationsScreen(),
    'Profile': () => const ProfileScreen(),
    'Help': () => const HelpSafetyScreen(),
    'StyleGuide': () => const StyleGuideScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} renders without errors', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: entry.value())),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });
  }
}
