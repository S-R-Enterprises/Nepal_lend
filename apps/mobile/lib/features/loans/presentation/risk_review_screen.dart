import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/features/loans/data/loan_controller.dart';
import 'package:nepal_lend/features/loans/presentation/loan_ui.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class RiskReviewScreen extends ConsumerStatefulWidget {
  const RiskReviewScreen({super.key, required this.loanId});

  final String loanId;

  @override
  ConsumerState<RiskReviewScreen> createState() => _RiskReviewScreenState();
}

class _RiskReviewScreenState extends ConsumerState<RiskReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(loanControllerProvider.notifier).load(widget.loanId);
    });
  }

  Future<void> _approve() async {
    final loan = await ref
        .read(loanControllerProvider.notifier)
        .approve(widget.loanId);
    if (!mounted || loan == null) return;
    setState(() {});
  }

  Future<void> _continue(Loan loan) async {
    if (loan.status == LoanStatus.draft) {
      final updated = await ref
          .read(loanControllerProvider.notifier)
          .submitForReview(widget.loanId);
      if (!mounted || updated == null) return;
      loan = updated;
    }
    if (mounted) {
      context.go('/borrower/loan-agreement/${widget.loanId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final state = ref.watch(loanControllerProvider);
    final loan = state.current?.id == widget.loanId ? state.current : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.riskReviewTitle)),
      body: SafeArea(
        child: ScreenStateView(
                isLoading: loan == null,
                isEmpty: false,
                error: state.error,
                onRetry: () =>
                    ref.read(loanControllerProvider.notifier).load(widget.loanId),
                builder: (_) => SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        StatusChip(
                          label: loanStatusLabel(loan!.status, l10n),
                          tone: loanStatusTone(loan.status),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                loan.purpose,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AmountText(paisa: loan.amountPaisa, large: true),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.loanTermsSummary(
                                  loan.tenorMonths,
                                  formatBps(loan.rateBps),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  if (loan.riskGrade != null)
                                    RiskBadge(
                                      grade: loan.riskGrade!,
                                      band: loan.riskBand?.name ?? 'high',
                                    ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Flexible(
                                    child: Text(
                                      l10n.riskScoreText(
                                        loan.assessment?.score ?? 0,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _RepaymentCard(loan: loan),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.whyThisGradeTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...?loan.assessment?.factors.map(
                          (factor) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AppCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StatusChip(
                                    label: riskDirectionMarker(
                                      factor.direction,
                                      l10n,
                                    ),
                                    tone: riskDirectionTone(factor.direction),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          factor.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        Text(factor.note),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.riskModelExplanation(
                            loan.assessment?.modelVersion ?? 'v1',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (loan.status == LoanStatus.pendingReview) ...[
                          Text(l10n.manualReviewNotice),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            label: l10n.demoApproveRequestButton,
                            variant: AppButtonVariant.secondary,
                            expand: true,
                            loading: state.busy,
                            onPressed: _approve,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        AppButton(
                          label: l10n.continueToAgreementButton,
                          expand: true,
                          onPressed: loan.status == LoanStatus.pendingReview
                              ? null
                              : () => _continue(loan),
                        ),
                      ],
                    ),
                ),
              ),
      ),
    );
  }
}

class _RepaymentCard extends StatelessWidget {
  const _RepaymentCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final emi = Money.installmentPaisa(
      principalPaisa: loan.amountPaisa,
      rateBps: loan.rateBps,
      tenorMonths: loan.tenorMonths,
    );
    final total = emi * loan.tenorMonths;
    final interest = total - loan.amountPaisa;
    final fee = Money.feeForInterest(interest);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.repaymentPreviewTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _row(context, l10n.monthlyInstalmentLabel, formatNPR(emi)),
          _row(context, l10n.totalRepayableLabel, formatNPR(total)),
          _row(context, l10n.interestLabel, formatNPR(interest)),
          _row(context, l10n.platformFeeLabel, formatNPR(fee)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}
