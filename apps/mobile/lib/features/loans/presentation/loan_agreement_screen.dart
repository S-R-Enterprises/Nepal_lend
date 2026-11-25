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
import 'package:nepal_lend/features/loans/data/loan_terms.dart';
import 'package:nepal_lend/features/loans/presentation/loan_ui.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class LoanAgreementScreen extends ConsumerStatefulWidget {
  const LoanAgreementScreen({super.key, required this.loanId});

  final String loanId;

  @override
  ConsumerState<LoanAgreementScreen> createState() =>
      _LoanAgreementScreenState();
}

class _LoanAgreementScreenState extends ConsumerState<LoanAgreementScreen> {
  final _signedBy = TextEditingController();
  bool _accepted = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(loanControllerProvider.notifier).load(widget.loanId);
    });
  }

  @override
  void dispose() {
    _signedBy.dispose();
    super.dispose();
  }

  Future<void> _sign(Loan loan) async {
    final l10n = L10n.of(context);
    setState(() => _localError = null);
    if (_signedBy.text.trim().isEmpty) {
      setState(() => _localError = l10n.typeFullNameToSignError);
      return;
    }
    if (!_accepted) {
      setState(() => _localError = l10n.acceptTermsBeforeSigningError);
      return;
    }
    final signed = await ref.read(loanControllerProvider.notifier).signAgreement(
          id: widget.loanId,
          signedBy: _signedBy.text.trim(),
        );
    if (!mounted || signed == null) return;
    final journalId = signed.agreement?.disbursementJournalId;
    if (journalId != null && journalId.isNotEmpty) {
      context.go('/wallet/transactions/$journalId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final state = ref.watch(loanControllerProvider);
    final loan = state.current?.id == widget.loanId ? state.current : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loanAgreementTitle)),
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
                                l10n.termsVersionText(LoanTerms.version),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                LoanTerms.text(
                                  amountPaisa: loan.amountPaisa,
                                  rateBps: loan.rateBps,
                                  tenorMonths: loan.tenorMonths,
                                  purpose: loan.purpose,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                l10n.termsHashText(LoanTerms.hash(
                                  LoanTerms.text(
                                    amountPaisa: loan.amountPaisa,
                                    rateBps: loan.rateBps,
                                    tenorMonths: loan.tenorMonths,
                                    purpose: loan.purpose,
                                  ),
                                )),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _ScheduleCard(loan: loan),
                        const SizedBox(height: AppSpacing.lg),
                        if (loan.agreement != null) ...[
                          StatusChip(
                            label: l10n.signedFundsDisbursedChip,
                            tone: AppTone.success,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.signedByOnText(
                              loan.agreement!.signedAt.toLocal(),
                              loan.agreement!.signedBy,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: l10n.viewDisbursementReceiptButton,
                            expand: true,
                            variant: AppButtonVariant.secondary,
                            onPressed: () => context.go(
                              '/wallet/transactions/'
                              '${loan.agreement!.disbursementJournalId}',
                            ),
                          ),
                        ] else ...[
                          AppInput(
                            label: l10n.typeFullNameToSignLabel,
                            hint: l10n.legalNameHint,
                            controller: _signedBy,
                          ),
                          CheckboxListTile(
                            value: _accepted,
                            onChanged: (value) =>
                                setState(() => _accepted = value ?? false),
                            title: Text(l10n.acceptTermsCheckboxLabel),
                          ),
                          if (_localError != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _localError!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: l10n.signAndReceiveFundsButton,
                            expand: true,
                            loading: state.busy,
                            onPressed: loan.status == LoanStatus.pendingReview
                                ? null
                                : () => _sign(loan),
                          ),
                          if (loan.status == LoanStatus.pendingReview) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(l10n.approveBeforeSigningNotice),
                          ],
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.demoEscrowNote,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ),
              ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final schedule = loan.instalments.isNotEmpty
        ? loan.instalments
        : _preview(loan);
    final total = schedule.fold<int>(
      0,
      (sum, item) => sum + item.totalPaisa,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.repaymentScheduleWithCount(schedule.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...schedule.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(l10n.instalmentNumberText(item.number)),
                  ),
                  Expanded(
                    child: Text(
                      l10n.displayDate(
                        item.dueDate.day,
                        item.dueDate.month,
                        item.dueDate.year,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      formatNPRCompact(item.totalPaisa),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(l10n.totalRepayableLabel)),
              Flexible(
                child: Text(
                  formatNPR(total),
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Instalment> _preview(Loan loan) {
    final amounts = Money.schedule(
      principalPaisa: loan.amountPaisa,
      rateBps: loan.rateBps,
      tenorMonths: loan.tenorMonths,
    );
    return amounts
        .map(
          (item) => Instalment(
            id: 'preview-${item.number}',
            loanId: loan.id,
            number: item.number,
            dueDate: item.dueDate,
            principalPaisa: item.principalPaisa,
            interestPaisa: item.interestPaisa,
          ),
        )
        .toList(growable: false);
  }
}
