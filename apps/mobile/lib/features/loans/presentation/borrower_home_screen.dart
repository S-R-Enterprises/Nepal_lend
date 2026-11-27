import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/loans/data/loan_controller.dart';
import 'package:nepal_lend/features/notifications/presentation/notification_badge.dart';
import 'package:nepal_lend/features/loans/presentation/loan_ui.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class BorrowerHomeScreen extends ConsumerStatefulWidget {
  const BorrowerHomeScreen({super.key});

  @override
  ConsumerState<BorrowerHomeScreen> createState() => _BorrowerHomeScreenState();
}

class _BorrowerHomeScreenState extends ConsumerState<BorrowerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(loanControllerProvider.notifier).loadMine();
    });
  }

  void _open(Loan loan) {
    switch (loan.status) {
      case LoanStatus.funded:
        context.go('/borrower/loan-agreement/${loan.id}');
      case LoanStatus.active:
      case LoanStatus.overdue:
        context.go('/borrower/repay/${loan.id}');
      case LoanStatus.repaid:
      case LoanStatus.defaulted:
        final journalId = loan.agreement?.disbursementJournalId;
        if (journalId != null && journalId.isNotEmpty) {
          context.go('/wallet/transactions/$journalId');
        }
      default:
        context.go('/borrower/risk-review/${loan.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final state = ref.watch(loanControllerProvider);
    final name = ref.watch(authProvider).user?.name ?? l10n.borrowerFallbackName;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.borrowerHomeTitle),
        actions: const [NotificationBadge()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.namasteGreeting(name),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.borrowerHomeIntro,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.requestLoanButton,
                icon: Icons.add_outlined,
                expand: true,
                onPressed: () => context.go('/borrower/request-loan'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.makeRepaymentButton,
                icon: Icons.payment_outlined,
                variant: AppButtonVariant.secondary,
                expand: true,
                onPressed: () => context.go('/borrower/repay'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.yourApplicationsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (state.busy)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ScreenStateView(
                isLoading: state.busy && state.loans.isEmpty,
                isEmpty: state.loans.isEmpty,
                error: state.error,
                onRetry: () =>
                    ref.read(loanControllerProvider.notifier).loadMine(),
                emptyTitle: l10n.noLoanRequestsYet,
                emptyMessage: l10n.noLoanRequestsMessage,
                builder: (_) => ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.loans.length,
                  itemBuilder: (context, index) => _LoanTile(
                    loan: state.loans[index],
                    onTap: () => _open(state.loans[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanTile extends StatelessWidget {
  const _LoanTile({required this.loan, required this.onTap});

  final Loan loan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    loan.purpose,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusChip(
                  label: loanStatusLabel(loan.status, l10n),
                  tone: loanStatusTone(loan.status),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(formatNPRCompact(loan.amountPaisa)),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.tenorMonthsText(loan.tenorMonths),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                if (loan.riskGrade != null)
                  RiskBadge(
                    grade: loan.riskGrade!,
                    band: loan.riskBand?.name ?? 'high',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
