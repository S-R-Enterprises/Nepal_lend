import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/registration_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/borrower/presentation/borrower_home_screen.dart';
import '../../features/borrower/presentation/loan_agreement_screen.dart';
import '../../features/borrower/presentation/repay_screen.dart';
import '../../features/borrower/presentation/request_loan_screen.dart';
import '../../features/borrower/presentation/risk_review_screen.dart';
import '../../features/help/presentation/help_safety_screen.dart';
import '../../features/kyc/presentation/kyc_screen.dart';
import '../../features/lender/presentation/browse_loans_screen.dart';
import '../../features/lender/presentation/fund_loan_sheet.dart';
import '../../features/lender/presentation/funding_success_screen.dart';
import '../../features/lender/presentation/lender_home_screen.dart';
import '../../features/lender/presentation/loan_details_screen.dart';
import '../../features/lender/presentation/loan_stake_detail_screen.dart';
import '../../features/lender/presentation/portfolio_screen.dart';
import '../../features/lender/presentation/transaction_detail_screen.dart';
import '../../features/lender/presentation/wallet_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/style_guide/presentation/style_guide_screen.dart';
import '../../routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: <RouteBase>[
    // Onboarding / auth
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: Routes.roleSelection,
      name: 'roleSelection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: Routes.registration,
      name: 'registration',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: Routes.otp,
      name: 'otp',
        builder: (context, state) => OTPScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          phone: state.uri.queryParameters['phone'] ?? '',
          devCode: state.uri.queryParameters['devCode'] ?? '',
        ),
    ),
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.kyc,
      name: 'kyc',
      builder: (context, state) => const KYCScreen(),
    ),

    // Lender
    GoRoute(
      path: Routes.lenderHome,
      name: 'lenderHome',
      builder: (context, state) => const LenderHomeScreen(),
    ),
    GoRoute(
      path: Routes.browseLoans,
      name: 'browseLoans',
      builder: (context, state) => const BrowseLoansScreen(),
    ),
    GoRoute(
      path: Routes.loanDetails,
      name: 'loanDetails',
      builder: (context, state) => const LoanDetailsScreen(),
    ),
    GoRoute(
      path: Routes.fundLoan,
      name: 'fundLoan',
      builder: (context, state) => const _FundLoanPage(),
    ),
    GoRoute(
      path: Routes.fundingSuccess,
      name: 'fundingSuccess',
      builder: (context, state) => FundingSuccessScreen(
        partial: state.uri.queryParameters['partial'] == 'true',
      ),
    ),
    GoRoute(
      path: Routes.portfolio,
      name: 'portfolio',
      builder: (context, state) => const PortfolioScreen(),
    ),
    GoRoute(
      path: Routes.loanStake,
      name: 'loanStake',
      builder: (context, state) => const LoanStakeDetailScreen(),
    ),
    GoRoute(
      path: Routes.wallet,
      name: 'wallet',
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: Routes.transaction,
      name: 'transaction',
      builder: (context, state) => const TransactionDetailScreen(),
    ),

    // Borrower
    GoRoute(
      path: Routes.borrowerHome,
      name: 'borrowerHome',
      builder: (context, state) => const BorrowerHomeScreen(),
    ),
    GoRoute(
      path: Routes.requestLoan,
      name: 'requestLoan',
      builder: (context, state) => const RequestLoanScreen(),
    ),
    GoRoute(
      path: Routes.riskReview,
      name: 'riskReview',
      builder: (context, state) => const RiskReviewScreen(),
    ),
    GoRoute(
      path: Routes.loanAgreement,
      name: 'loanAgreement',
      builder: (context, state) => const LoanAgreementScreen(),
    ),
    GoRoute(
      path: Routes.repay,
      name: 'repay',
      builder: (context, state) => const RepayScreen(),
    ),

    // Shared
    GoRoute(
      path: Routes.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: Routes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: Routes.help,
      name: 'help',
      builder: (context, state) => const HelpSafetyScreen(),
    ),
    GoRoute(
      path: '/style-guide',
      name: 'styleGuide',
      builder: (context, state) => const StyleGuideScreen(),
    ),
  ],
);

class _FundLoanPage extends StatelessWidget {
  const _FundLoanPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: FundLoanSheet(),
      ),
    );
  }
}
