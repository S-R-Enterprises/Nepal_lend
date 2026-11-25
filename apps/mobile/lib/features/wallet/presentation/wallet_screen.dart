import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/features/wallet/data/wallet_controller.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(walletControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final state = ref.watch(walletControllerProvider);
    final snapshot = state.snapshot;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.availableBalanceLabel,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AmountText(
                      paisa: snapshot?.balancePaisa ?? 0,
                      large: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.topUpButton,
                      icon: Icons.add_outlined,
                      expand: true,
                      onPressed: () => context.go('/lender/wallet/topup'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: l10n.withdrawButton,
                      variant: AppButtonVariant.secondary,
                      icon: Icons.remove_outlined,
                      expand: true,
                      onPressed: () => context.go('/lender/wallet/withdraw'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.recentActivityTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ScreenStateView(
                  isLoading: state.busy && snapshot == null,
                  isEmpty: snapshot == null || snapshot.transactions.isEmpty,
                  error: state.error,
                  onRetry: () =>
                      ref.read(walletControllerProvider.notifier).load(),
                  emptyTitle: l10n.noWalletActivityYet,
                  emptyMessage: l10n.noWalletActivityMessage,
                  builder: (_) => ListView.separated(
                    itemCount: snapshot!.transactions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final tx = snapshot.transactions[index];
                      return AppCard(
                        onTap: () => context.go('/wallet/transactions/${tx.id}'),
                        child: Row(
                          children: [
                            Icon(
                              tx.amountPaisa >= 0
                                  ? Icons.arrow_downward_outlined
                                  : Icons.arrow_upward_outlined,
                              color: tx.amountPaisa >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx.title),
                                  Text(
                                    formatNPR(tx.amountPaisa),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      );
                    },
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
