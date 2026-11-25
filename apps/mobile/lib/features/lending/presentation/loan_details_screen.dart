import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/features/lending/data/lending_controller.dart';
import 'package:nepal_lend/features/lending/presentation/lending_ui.dart';
import 'package:nepal_lend/features/loans/presentation/loan_ui.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class LoanDetailsScreen extends ConsumerStatefulWidget {
  const LoanDetailsScreen({super.key, required this.loanId});

  final String loanId;

  @override
  ConsumerState<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends ConsumerState<LoanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(lendingControllerProvider.notifier).loadLoan(widget.loanId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lendingControllerProvider);
    final l10n = L10n.of(context);
    final loan = state.currentLoan?.id == widget.loanId
        ? state.currentLoan
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loanDetailsTitle)),
      body: SafeArea(
        child: ScreenStateView(
                isLoading: loan == null,
                isEmpty: false,
                error: state.error,
                onRetry: () => ref
                    .read(lendingControllerProvider.notifier)
                    .loadLoan(widget.loanId),
                builder: (_) => SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loan!.purpose,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            StatusChip(
                              label: loanStatusLabel(loan.status, l10n),
                              tone: loanStatusTone(loan.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AmountText(paisa: loan.amountPaisa, large: true),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.loanTermsSummary(
                                  loan.tenorMonths,
                                  formatBps(loan.rateBps),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              FundingProgress(
                                fundedPaisa: loan.fundedPaisa,
                                amountPaisa: loan.amountPaisa,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.needsMoreByDate(
                                  formatNPRCompact(loan.remainingPaisa),
                                  _date(context, loan.fundingDeadline),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppCard(
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user_outlined,
                                  color: AppColors.success),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      borrowerLabel(context, loan),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      l10n.identityVerifiedNote,
                                      style: const TextStyle(
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (loan.riskGrade != null)
                                RiskBadge(
                                  grade: loan.riskGrade!,
                                  band: loan.riskBand?.name ?? 'high',
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.riskFactorsTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...?loan.assessment?.factors.map(
                          (factor) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AppCard(
                              child: Text(
                                l10n.riskFactorLine(factor.name, factor.note),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.modelScoreSummary(
                            loan.assessment?.modelVersion ?? 'v1',
                            loan.assessment?.score ?? 0,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: l10n.fundThisLoanButton,
                          icon: Icons.account_balance_wallet_outlined,
                          expand: true,
                          onPressed: loan.canFund
                              ? () => context
                                  .go('/lender/fund-loan/${widget.loanId}')
                              : null,
                        ),
                        if (!loan.canFund) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.loanNotOpenForFunding,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ],
                    ),
                ),
              ),
      ),
    );
  }

  String _date(BuildContext context, DateTime? date) {
    final l10n = L10n.of(context);
    return date == null
        ? l10n.dateToBeConfirmed
        : l10n.displayDate(date.day, date.month, date.year);
  }
}
