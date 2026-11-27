import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/features/lending/data/lending_controller.dart';
import 'package:nepal_lend/features/notifications/presentation/notification_badge.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class LenderHomeScreen extends ConsumerStatefulWidget {
  const LenderHomeScreen({super.key});

  @override
  ConsumerState<LenderHomeScreen> createState() => _LenderHomeScreenState();
}

class _LenderHomeScreenState extends ConsumerState<LenderHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(lendingControllerProvider.notifier)
        ..browse()
        ..loadStakes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lendingControllerProvider);
    final l10n = L10n.of(context);
    var active = 0;
    var committed = 0;
    for (final stake in state.stakes) {
      if (!stake.isActive) continue;
      active++;
      committed += stake.amountPaisa;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lenderHomeTitle),
        actions: const [NotificationBadge()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.lenderHomeIntro,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.walletBalanceLabel,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AmountText(paisa: state.walletBalancePaisa, large: true),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.activeStakesLabel),
                        Text(
                          l10n.activeStakesCount(active),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.amountCommittedLabel),
                        Text(
                          formatNPRCompact(committed),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.browseVerifiedLoansButton,
                icon: Icons.search_outlined,
                expand: true,
                onPressed: () => context.go('/lender/browse'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.viewMyPortfolioButton,
                icon: Icons.pie_chart_outline,
                variant: AppButtonVariant.secondary,
                expand: true,
                onPressed: () => context.go('/lender/portfolio'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.addMoneyToWalletButton,
                icon: Icons.add_outlined,
                variant: AppButtonVariant.text,
                expand: true,
                onPressed: () => context.go('/lender/wallet/topup'),
              ),
              const SizedBox(height: AppSpacing.md),
              ScreenStateView(
                isLoading: state.busy && state.loans.isEmpty,
                isEmpty: state.loans.isEmpty,
                error: state.error,
                onRetry: () {
                  ref.read(lendingControllerProvider.notifier)
                    ..browse()
                    ..loadStakes();
                },
                emptyTitle: l10n.openLoansTitle,
                builder: (_) => Text(
                  state.loans.length == 1
                      ? l10n.openLoansSummarySingular(state.loans.length)
                      : l10n.openLoansSummary(state.loans.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
