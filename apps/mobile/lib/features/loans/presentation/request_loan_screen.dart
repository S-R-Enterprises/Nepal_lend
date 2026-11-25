import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/features/loans/data/loan_controller.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class RequestLoanScreen extends ConsumerStatefulWidget {
  const RequestLoanScreen({super.key});

  @override
  ConsumerState<RequestLoanScreen> createState() => _RequestLoanScreenState();
}

class _RequestLoanScreenState extends ConsumerState<RequestLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purpose = TextEditingController();
  final _amount = TextEditingController();
  final _tenor = TextEditingController(text: '12');
  final _income = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _purpose.dispose();
    _amount.dispose();
    _tenor.dispose();
    _income.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = L10n.of(context);
    setState(() => _localError = null);
    if (!_formKey.currentState!.validate()) return;

    final amount = Money.parseNpr(_amount.text);
    final tenor = int.tryParse(_tenor.text.trim()) ?? 0;
    final income = Money.parseNpr(_income.text);
    if (amount < ProductRules.minLoanPaisa ||
        amount > ProductRules.maxLoanPaisa) {
      setState(() => _localError = l10n.loanAmountOutOfRangeError(
            formatNPRCompact(ProductRules.maxLoanPaisa),
            formatNPRCompact(ProductRules.minLoanPaisa),
          ));
      return;
    }
    if (tenor < 3 || tenor > 60) {
      setState(() => _localError = l10n.invalidTenorRangeError);
      return;
    }
    if (income <= 0) {
      setState(() => _localError = l10n.enterMonthlyIncomeError);
      return;
    }

    final loan = await ref.read(loanControllerProvider.notifier).createApplication(
          purpose: _purpose.text.trim(),
          amountPaisa: amount,
          tenorMonths: tenor,
          monthlyIncomePaisa: income,
        );
    if (!mounted || loan == null) return;
    context.go('/borrower/risk-review/${loan.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final busy = ref.watch(loanControllerProvider).busy;
    final error = ref.watch(loanControllerProvider).error;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestLoanTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.requestLoanIntro,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppInput(
                  label: l10n.purposeLabel,
                  hint: l10n.purposeHint,
                  controller: _purpose,
                  maxLines: 2,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.describePurposeError
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppInput(
                  label: l10n.loanAmountLabel,
                  hint: l10n.loanAmountHint,
                  prefixText: l10n.nprPrefix,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  controller: _amount,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.enterAmountError
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppInput(
                  label: l10n.tenorLabel,
                  hint: l10n.tenorHint,
                  keyboardType: TextInputType.number,
                  controller: _tenor,
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null) return l10n.enterWholeMonthsError;
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppInput(
                  label: l10n.monthlyIncomeLabel,
                  hint: l10n.monthlyIncomeHint,
                  prefixText: l10n.nprPrefix,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  controller: _income,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.enterMonthlyIncomeError
                      : null,
                ),
                if (_localError != null || error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _localError ?? error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.seeMyRiskGradeButton,
                  expand: true,
                  loading: busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.requestLoanDemoNote,
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
