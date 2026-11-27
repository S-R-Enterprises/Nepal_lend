import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/features/lending/data/lending_controller.dart';
import 'package:nepal_lend/l10n/l10n.dart';
import 'package:uuid/uuid.dart';

class FundLoanScreen extends ConsumerStatefulWidget {
  const FundLoanScreen({super.key, required this.loanId});

  final String loanId;

  @override
  ConsumerState<FundLoanScreen> createState() => _FundLoanScreenState();
}

class _FundLoanScreenState extends ConsumerState<FundLoanScreen> {
  static const Uuid _uuid = Uuid();

  final _amount = TextEditingController();
  String? _localError;
  int? _cachedTotalInterestPaisa;
  int? _cachedAmountPaisa;
  int? _cachedRateBps;
  int? _cachedTenorMonths;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(lendingControllerProvider.notifier)
          .loadLoan(widget.loanId)
          .then((loan) {
        if (!mounted || loan == null || _amount.text.isNotEmpty) return;
        setState(() => _amount.text = (loan.remainingPaisa ~/ 100).toString());
      });
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  int _totalInterestPaisa(Loan loan) {
    if (_cachedTotalInterestPaisa == null ||
        _cachedAmountPaisa != loan.amountPaisa ||
        _cachedRateBps != loan.rateBps ||
        _cachedTenorMonths != loan.tenorMonths) {
      _cachedTotalInterestPaisa = Money.schedule(
        principalPaisa: loan.amountPaisa,
        rateBps: loan.rateBps,
        tenorMonths: loan.tenorMonths,
      ).fold<int>(0, (sum, item) => sum + item.interestPaisa);
      _cachedAmountPaisa = loan.amountPaisa;
      _cachedRateBps = loan.rateBps;
      _cachedTenorMonths = loan.tenorMonths;
    }
    return _cachedTotalInterestPaisa!;
  }

  int _interestShare(Loan loan, int amount) {
    if (loan.amountPaisa <= 0 || amount <= 0) return 0;
    return Money.roundDiv(_totalInterestPaisa(loan) * amount, loan.amountPaisa);
  }

  Future<void> _confirm(Loan loan) async {
    final l10n = L10n.of(context);
    setState(() => _localError = null);
    final amount = Money.parseNpr(_amount.text);
    if (amount < ProductRules.minStakePaisa) {
      setState(() => _localError = l10n.minimumStakeError(
            formatNPRCompact(ProductRules.minStakePaisa),
          ));
      return;
    }
    if (amount > loan.remainingPaisa) {
      setState(() => _localError = l10n.onlyStillNeededError(
            formatNPRCompact(loan.remainingPaisa),
          ));
      return;
    }
    final balance = ref.read(lendingControllerProvider).walletBalancePaisa;
    if (amount > balance) {
      setState(() => _localError = l10n.topUpWalletFirstError);
      return;
    }

    final stake = await ref.read(lendingControllerProvider.notifier).fund(
          loanId: loan.id,
          amountPaisa: amount,
          idempotencyKey: 'fund-${loan.id}-${_uuid.v4()}',
        );
    if (!mounted || stake == null) return;
    context.go('/stakes/${stake.id}');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lendingControllerProvider);
    final l10n = L10n.of(context);
    final loan = state.currentLoan?.id == widget.loanId
        ? state.currentLoan
        : null;
    final amount = Money.parseNpr(_amount.text);
    final interest = loan == null ? 0 : _interestShare(loan, amount);
    final fee = Money.feeForInterest(interest);
    final walletAfter = state.walletBalancePaisa - amount;
    final canFund = loan?.canFund ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fundLoanTitle)),
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
                        Text(
                          loan!.purpose,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.stillNeededOfTotalText(
                            formatNPRCompact(loan.remainingPaisa),
                            formatNPRCompact(loan.amountPaisa),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppInput(
                          label: l10n.amountToStakeLabel,
                          hint: l10n.amountToStakeHint,
                          prefixText: l10n.nprPrefix,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          controller: _amount,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SummaryRow(
                                label: l10n.walletBeforeLabel,
                                value: formatNPR(state.walletBalancePaisa),
                              ),
                              _SummaryRow(
                                label: l10n.interestShareLabel,
                                value: formatNPR(interest),
                              ),
                              _SummaryRow(
                                label: l10n.platformFeeLabel,
                                value: formatNPR(fee),
                              ),
                              const Divider(),
                              _SummaryRow(
                                label: l10n.walletAfterLabel,
                                value: formatNPR(walletAfter),
                                danger: walletAfter < 0,
                              ),
                            ],
                          ),
                        ),
                        if (_localError != null || state.error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _localError ?? state.error!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: l10n.confirmFundingButton,
                          expand: true,
                          loading: state.busy,
                          onPressed: canFund
                              ? () => _confirm(loan)
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.demoFundingNote,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                ),
              ),
      ),
    );
  }

}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.danger = false,
  });

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) => Padding(
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: danger ? AppColors.error : null,
                ),
              ),
            ),
          ],
        ),
      );
}
