import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_lend/screens/borrower/borrower_home_screen.dart';
import 'package:nepal_lend/screens/borrower/loan_agreement_screen.dart';
import 'package:nepal_lend/screens/borrower/repay_screen.dart';
import 'package:nepal_lend/screens/borrower/request_loan_screen.dart';
import 'package:nepal_lend/screens/borrower/risk_review_screen.dart';
import 'package:nepal_lend/screens/lender/browse_loans_screen.dart';
import 'package:nepal_lend/screens/lender/funding_success_screen.dart';
import 'package:nepal_lend/screens/lender/lender_home_screen.dart';
import 'package:nepal_lend/screens/lender/loan_details_screen.dart';
import 'package:nepal_lend/screens/lender/loan_stake_detail_screen.dart';
import 'package:nepal_lend/screens/lender/portfolio_screen.dart';
import 'package:nepal_lend/screens/lender/transaction_detail_screen.dart';
import 'package:nepal_lend/screens/lender/wallet_screen.dart';
import 'package:nepal_lend/screens/onboarding/kyc_screen.dart';
import 'package:nepal_lend/screens/onboarding/login_screen.dart';
import 'package:nepal_lend/screens/onboarding/onboarding_screen.dart';
import 'package:nepal_lend/screens/onboarding/otp_screen.dart';
import 'package:nepal_lend/screens/onboarding/registration_screen.dart';
import 'package:nepal_lend/screens/onboarding/role_selection_screen.dart';
import 'package:nepal_lend/screens/shared/help_safety_screen.dart';
import 'package:nepal_lend/screens/shared/notifications_screen.dart';
import 'package:nepal_lend/screens/shared/profile_screen.dart';
import 'package:nepal_lend/screens/style_guide_screen.dart';

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
        MaterialApp(home: Scaffold(body: entry.value())),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });
  }
}
