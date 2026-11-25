import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/router/app_shell.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/auth/presentation/login_screen.dart';
import 'package:nepal_lend/features/auth/presentation/onboarding_screen.dart';
import 'package:nepal_lend/features/auth/presentation/otp_screen.dart';
import 'package:nepal_lend/features/auth/presentation/role_selection_screen.dart';
import 'package:nepal_lend/features/kyc/presentation/kyc_checklist_screen.dart';
import 'package:nepal_lend/features/kyc/presentation/kyc_step_screen.dart';
import 'package:nepal_lend/features/lending/presentation/fund_loan_screen.dart';
import 'package:nepal_lend/features/lending/presentation/lender_browse_screen.dart';
import 'package:nepal_lend/features/lending/presentation/lender_home_screen.dart';
import 'package:nepal_lend/features/lending/presentation/lender_portfolio_screen.dart';
import 'package:nepal_lend/features/lending/presentation/loan_details_screen.dart';
import 'package:nepal_lend/features/lending/presentation/stake_detail_screen.dart';
import 'package:nepal_lend/features/loans/data/loan_controller.dart';
import 'package:nepal_lend/features/loans/presentation/borrower_home_screen.dart';
import 'package:nepal_lend/features/loans/presentation/loan_agreement_screen.dart';
import 'package:nepal_lend/features/loans/presentation/request_loan_screen.dart';
import 'package:nepal_lend/features/loans/presentation/risk_review_screen.dart';
import 'package:nepal_lend/features/notifications/presentation/notifications_screen.dart';
import 'package:nepal_lend/features/repayments/presentation/repayment_screen.dart';
import 'package:nepal_lend/features/styleguide/presentation/style_guide_screen.dart';
import 'package:nepal_lend/features/wallet/presentation/transaction_receipt_screen.dart';
import 'package:nepal_lend/features/wallet/presentation/wallet_action_screen.dart';
import 'package:nepal_lend/features/wallet/presentation/wallet_screen.dart';
import 'package:nepal_lend/l10n/l10n.dart';
import 'package:nepal_lend/shared/widgets/placeholder_screen.dart';

const Set<String> _authRoutes = {
  '/splash',
  '/onboarding',
  '/login',
  '/otp',
  '/role-selection',
};

const Set<String> _publicRoutes = {
  '/help',
  '/style-guide',
};

/// Pure redirect logic so it can be unit-tested without a widget tree.
String? authRedirect(AuthState auth, String location) {
  if (auth.status == AuthStatus.unknown) {
    return location == '/splash' ? null : '/splash';
  }
  if (auth.status == AuthStatus.signedOut) {
    if (location == '/otp' && auth.pendingPhone == null) return '/login';
    // The splash is only valid while auth is unknown. Once restore finishes
    // with no session, move on instead of leaving the spinner on screen.
    if (location == '/splash') return '/login';
    if (_authRoutes.contains(location) || _publicRoutes.contains(location)) {
      return null;
    }
    return '/login';
  }

  final user = auth.user;
  if (user == null) return '/splash';
  if (user.status == AccountStatus.suspended) return '/help';

  if (user.role == null) {
    return location == '/role-selection' ? null : '/role-selection';
  }
  final isKycRoute = location == '/kyc' || location.startsWith('/kyc/');
  if (!user.isVerified) {
    return isKycRoute ? null : '/kyc';
  }

  final home = user.role == UserRole.borrower
      ? '/borrower/home'
      : '/lender/home';
  if (_authRoutes.contains(location) || isKycRoute) return home;
  final isLenderOnly =
      location.startsWith('/lender') || location.startsWith('/stakes');
  if (user.role == UserRole.borrower && isLenderOnly) return home;
  if (user.role == UserRole.lender && location.startsWith('/borrower')) {
    return home;
  }
  return null;
}

/// Tells GoRouter to re-evaluate [authRedirect] when login/role/KYC changes.
/// The router instance itself is stable, so navigation is not reset.
final _authRefresh = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen<AuthState>(authProvider, (_, _) => notifier.value++);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: ref.watch(_authRefresh),
    redirect: (context, state) =>
        authRedirect(ref.read(authProvider), state.matchedLocation),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) => const KycChecklistScreen(),
      ),
      GoRoute(
        path: '/kyc/:step',
        builder: (context, state) {
          final name = state.pathParameters['step'];
          for (final kind in KycStepKind.values) {
            if (kind.name == name) return KycStepScreen(kind: kind);
          }
          final l10n = L10n.of(context);
          return PlaceholderScreen(
            title: l10n.stepNotFoundTitle,
            icon: Icons.error_outline,
            description: l10n.stepNotFoundDescription,
          );
        },
      ),
      GoRoute(
        path: '/style-guide',
        builder: (context, state) => const StyleGuideScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) {
          final l10n = L10n.of(context);
          return PlaceholderScreen(
            title: l10n.helpAndSafetyTitle,
            icon: Icons.help_outline,
            description: l10n.helpAndSafetyDescription,
          );
        },
      ),
      GoRoute(
        path: '/borrower/request-loan',
        builder: (context, state) => const RequestLoanScreen(),
      ),
      GoRoute(
        path: '/borrower/risk-review',
        redirect: (context, state) {
          final loans = ref.read(loanControllerProvider).loans;
          return loans.isEmpty
              ? '/borrower/request-loan'
              : '/borrower/risk-review/${loans.first.id}';
        },
      ),
      GoRoute(
        path: '/borrower/risk-review/:id',
        builder: (context, state) => RiskReviewScreen(
          loanId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/borrower/loan-agreement',
        redirect: (context, state) {
          final loans = ref.read(loanControllerProvider).loans;
          return loans.isEmpty
              ? '/borrower/request-loan'
              : '/borrower/loan-agreement/${loans.first.id}';
        },
      ),
      GoRoute(
        path: '/borrower/loan-agreement/:id',
        builder: (context, state) => LoanAgreementScreen(
          loanId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/borrower/repay',
        builder: (context, state) => const RepaymentScreen(),
      ),
      GoRoute(
        path: '/borrower/repay/:id',
        builder: (context, state) => RepaymentScreen(
          loanId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/lender/loan-details/:id',
        builder: (context, state) => LoanDetailsScreen(
          loanId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/lender/fund-loan/:id',
        builder: (context, state) => FundLoanScreen(
          loanId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/stakes/:id',
        builder: (context, state) => StakeDetailScreen(
          stakeId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/lender/wallet/topup',
        builder: (context, state) =>
            const WalletActionScreen(mode: WalletActionMode.topup),
      ),
      GoRoute(
        path: '/lender/wallet/withdraw',
        builder: (context, state) =>
            const WalletActionScreen(mode: WalletActionMode.withdrawal),
      ),
      GoRoute(
        path: '/wallet/transactions/:id',
        builder: (context, state) => TransactionReceiptScreen(
          journalId: state.pathParameters['id'] ?? '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/borrower/home',
                builder: (context, state) => const BorrowerHomeScreen(),
              ),
              GoRoute(
                path: '/borrower/loans',
                builder: (context, state) {
                  final l10n = L10n.of(context);
                  return PlaceholderScreen(
                    title: l10n.myLoansTitle,
                    icon: Icons.description_outlined,
                    description: l10n.myLoansDescription,
                  );
                },
              ),
              GoRoute(
                path: '/borrower/profile',
                builder: (context, state) {
                  final l10n = L10n.of(context);
                  return PlaceholderScreen(
                    title: l10n.borrowerProfileTitle,
                    icon: Icons.person_outline,
                    description: l10n.borrowerProfileDescription,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lender/home',
                builder: (context, state) => const LenderHomeScreen(),
              ),
              GoRoute(
                path: '/lender/browse',
                builder: (context, state) => const LenderBrowseScreen(),
              ),
              GoRoute(
                path: '/lender/portfolio',
                builder: (context, state) => const LenderPortfolioScreen(),
              ),
              GoRoute(
                path: '/lender/wallet',
                builder: (context, state) => const WalletScreen(),
              ),
              GoRoute(
                path: '/lender/profile',
                builder: (context, state) {
                  final l10n = L10n.of(context);
                  return PlaceholderScreen(
                    title: l10n.lenderProfileTitle,
                    icon: Icons.person_outline,
                    description: l10n.lenderProfileDescription,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
