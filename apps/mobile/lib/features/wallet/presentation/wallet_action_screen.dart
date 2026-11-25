import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/config/product_rules.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/money.dart';
import 'package:nepal_lend/features/wallet/data/wallet_controller.dart';
import 'package:nepal_lend/features/wallet/presentation/wallet_confirmation_sheet.dart';
import 'package:nepal_lend/l10n/l10n.dart';

enum WalletActionMode { topup, withdrawal }

class WalletActionScreen extends ConsumerStatefulWidget {
  const WalletActionScreen({super.key, required this.mode});

  final WalletActionMode mode;

  @override
  ConsumerState<WalletActionScreen> createState() => _WalletActionScreenState();
}

class _WalletActionScreenState extends ConsumerState<WalletActionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String? _localError;

  bool get _isTopup => widget.mode == WalletActionMode.topup;

  @override
  void initState() {
    super.initState();
    if (!_isTopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(walletControllerProvider.notifier).load();
      });
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _review() {
    final l10n = L10n.of(context);
    setState(() => _localError = null);
    if (!_formKey.currentState!.validate()) return;
    final amount = Money.parseNpr(_amount.text);
    if (amount < ProductRules.minStakePaisa) {
      setState(() => _localError = l10n.minimumAmountError);
      return;
    }
    final balance = ref.read(walletControllerProvider).snapshot?.balancePaisa ?? 0;
    if (!_isTopup && amount > balance) {
      setState(() => _localError = l10n.amountExceedsBalanceError);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => WalletConfirmationSheet(
        title: _isTopup
            ? l10n.confirmTopUpSheetTitle
            : l10n.confirmWithdrawalSheetTitle,
        amountPaisa: amount,
        detail: _isTopup ? l10n.topUpSheetDetail : l10n.withdrawalSheetDetail,
        confirmLabel: _isTopup
            ? l10n.confirmTopUpButton
            : l10n.confirmWithdrawalButton,
        onConfirm: () => _submit(amount),
      ),
    );
  }

  Future<void> _submit(int amount) async {
    Navigator.of(context).pop();
    final controller = ref.read(walletControllerProvider.notifier);
    final receipt = _isTopup
        ? await controller.topUp(amount)
        : await controller.withdraw(amount);
    if (!mounted || receipt == null) return;
    context.go('/wallet/transactions/${receipt.journalId}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final state = ref.watch(walletControllerProvider);
    final balance = state.snapshot?.balancePaisa ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isTopup ? l10n.topUpWalletTitle : l10n.withdrawToBankTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isTopup ? l10n.topUpIntro : l10n.withdrawalIntro,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!_isTopup) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.availableBalanceLabel),
                        const SizedBox(height: AppSpacing.xs),
                        AmountText(paisa: balance),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                AppInput(
                  label: _isTopup
                      ? l10n.amountToAddLabel
                      : l10n.amountToWithdrawLabel,
                  hint: l10n.walletAmountHint,
                  prefixText: l10n.nprPrefix,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  controller: _amount,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.enterAmountError
                      : null,
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
                  label: _isTopup
                      ? l10n.reviewTopUpButton
                      : l10n.reviewWithdrawalButton,
                  expand: true,
                  loading: state.busy,
                  onPressed: _review,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.demoPaymentGatewayNote,
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
