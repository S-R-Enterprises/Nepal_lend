import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/lending/data/lending_controller.dart';
import 'package:nepal_lend/features/loans/presentation/loan_ui.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class LenderBrowseScreen extends ConsumerStatefulWidget {
  const LenderBrowseScreen({super.key});

  @override
  ConsumerState<LenderBrowseScreen> createState() => _LenderBrowseScreenState();
}

class _LenderBrowseScreenState extends ConsumerState<LenderBrowseScreen> {
  final _minAmount = TextEditingController();
  final _maxAmount = TextEditingController();
  final _maxTenor = TextEditingController();
  String _riskBand = 'all';
  String _sort = 'newest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _apply();
    });
  }

  @override
  void dispose() {
    _minAmount.dispose();
    _maxAmount.dispose();
    _maxTenor.dispose();
    super.dispose();
  }

  void _apply() {
    final min = _minAmount.text.trim().isEmpty
        ? null
        : Money.parseNpr(_minAmount.text);
    final max = _maxAmount.text.trim().isEmpty
        ? null
        : Money.parseNpr(_maxAmount.text);
    final tenor = int.tryParse(_maxTenor.text.trim());
    RiskBand? band;
    for (final value in RiskBand.values) {
      if (value.name == _riskBand) band = value;
    }
    ref.read(lendingControllerProvider.notifier).browse(
          riskBand: band,
          minAmountPaisa: min == null || min <= 0 ? null : min,
          maxAmountPaisa: max == null || max <= 0 ? null : max,
          maxTenorMonths: tenor == null || tenor <= 0 ? null : tenor,
          sort: _sort,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lendingControllerProvider);
    final l10n = L10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.browseLoansTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.fundVerifiedBorrower,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _riskBand,
                      decoration: InputDecoration(
                        labelText: l10n.riskBandLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(l10n.riskBandAll),
                        ),
                        DropdownMenuItem(
                          value: 'low',
                          child: Text(l10n.riskBandLow),
                        ),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Text(l10n.riskBandMedium),
                        ),
                        DropdownMenuItem(
                          value: 'high',
                          child: Text(l10n.riskBandHigh),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _riskBand = value ?? 'all'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppInput(
                            label: l10n.minAmountLabel,
                            hint: l10n.minAmountHint,
                            prefixText: l10n.nprPrefix,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            controller: _minAmount,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppInput(
                            label: l10n.maxAmountLabel,
                            hint: l10n.maxAmountHint,
                            prefixText: l10n.nprPrefix,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            controller: _maxAmount,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppInput(
                            label: l10n.maxTenorLabel,
                            hint: l10n.maxTenorHint,
                            keyboardType: TextInputType.number,
                            controller: _maxTenor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _sort,
                            decoration: InputDecoration(
                              labelText: l10n.sortLabel,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'newest',
                                child: Text(l10n.sortNewest),
                              ),
                              DropdownMenuItem(
                                value: 'amountAsc',
                                child: Text(l10n.sortAmountAscending),
                              ),
                              DropdownMenuItem(
                                value: 'amountDesc',
                                child: Text(l10n.sortAmountDescending),
                              ),
                              DropdownMenuItem(
                                value: 'risk',
                                child: Text(l10n.sortLowestRisk),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _sort = value ?? 'newest'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: l10n.applyFiltersButton,
                      variant: AppButtonVariant.secondary,
                      expand: true,
                      loading: state.busy,
                      onPressed: _apply,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.openLoansTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    l10n.openLoansCount(state.loans.length),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ScreenStateView(
                isLoading: state.busy && state.loans.isEmpty,
                isEmpty: state.loans.isEmpty,
                error: state.loans.isEmpty ? state.error : null,
                onRetry: _apply,
                emptyTitle: l10n.noLoansMatch,
                emptyMessage: l10n.noLoansMatchMessage,
                builder: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: state.loans.map(
                  (loan) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      onTap: () => context
                          .go('/lender/loan-details/${loan.id}'),
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
                              if (loan.riskGrade != null)
                                RiskBadge(
                                  grade: loan.riskGrade!,
                                  band: loan.riskBand?.name ?? 'high',
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Text(formatNPRCompact(loan.amountPaisa)),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                l10n.tenorMonthsShort(loan.tenorMonths),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              StatusChip(
                                label: loanStatusLabel(loan.status, l10n),
                                tone: loanStatusTone(loan.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          FundingProgress(
                            fundedPaisa: loan.fundedPaisa,
                            amountPaisa: loan.amountPaisa,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).toList(),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
