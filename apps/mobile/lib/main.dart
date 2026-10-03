import 'package:flutter/material.dart';

import 'routes.dart';
import 'features/borrower/presentation/borrower_home_screen.dart';
import 'features/borrower/presentation/loan_agreement_screen.dart';
import 'features/borrower/presentation/repay_screen.dart';
import 'features/borrower/presentation/request_loan_screen.dart';
import 'features/borrower/presentation/risk_review_screen.dart';
import 'features/lender/presentation/browse_loans_screen.dart';
import 'features/lender/presentation/fund_loan_sheet.dart';
import 'features/lender/presentation/funding_success_screen.dart';
import 'features/lender/presentation/lender_home_screen.dart';
import 'features/lender/presentation/loan_details_screen.dart';
import 'features/lender/presentation/loan_stake_detail_screen.dart';
import 'features/lender/presentation/portfolio_screen.dart';
import 'features/lender/presentation/transaction_detail_screen.dart';
import 'features/lender/presentation/wallet_screen.dart';
import 'features/kyc/presentation/kyc_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/auth/presentation/otp_screen.dart';
import 'features/auth/presentation/registration_screen.dart';
import 'features/auth/presentation/role_selection_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/help/presentation/help_safety_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/style_guide/presentation/style_guide_screen.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NepalLend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: kInter,
        scaffoldBackgroundColor: AppColors.surface,
        splashFactory: InkSparkle.splashFactory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          primary: AppColors.teal,
          onPrimary: AppColors.white,
          secondary: AppColors.navy,
          surface: AppColors.white,
          error: AppColors.danger,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          bodyMedium: AppText.body,
          bodySmall: AppText.bodySm,
          titleLarge: AppText.h2,
          titleMedium: AppText.h3,
          titleSmall: AppText.h4,
          labelMedium: AppText.label,
          labelSmall: AppText.caption,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          border: InputBorder.none,
        ),
      ),
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (_) => const SplashScreen(),
        Routes.onboarding: (_) => const OnboardingScreen(),
        Routes.roleSelection: (_) => const RoleSelectionScreen(),
        Routes.registration: (_) => const RegistrationScreen(),
        Routes.otp: (_) => const OTPScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.kyc: (_) => const KYCScreen(),

        Routes.lenderHome: (_) => const LenderHomeScreen(),
        Routes.browseLoans: (_) => const BrowseLoansScreen(),
        Routes.loanDetails: (_) => const LoanDetailsScreen(),
        Routes.fundLoan: (_) => const _FundLoanPage(),
        Routes.fundingSuccess: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          return FundingSuccessScreen(
            partial: args is Map && args['partial'] == true,
          );
        },
        Routes.portfolio: (_) => const PortfolioScreen(),
        Routes.loanStake: (_) => const LoanStakeDetailScreen(),
        Routes.wallet: (_) => const WalletScreen(),
        Routes.transaction: (_) => const TransactionDetailScreen(),

        Routes.borrowerHome: (_) => const BorrowerHomeScreen(),
        Routes.requestLoan: (_) => const RequestLoanScreen(),
        Routes.riskReview: (_) => const RiskReviewScreen(),
        Routes.loanAgreement: (_) => const LoanAgreementScreen(),
        Routes.repay: (_) => const RepayScreen(),

        Routes.notifications: (_) => const NotificationsScreen(),
        Routes.profile: (_) => const ProfileScreen(),
        Routes.help: (_) => const HelpSafetyScreen(),

        '/style-guide': (_) => const StyleGuideScreen(),
      },
    );
  }
}

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
