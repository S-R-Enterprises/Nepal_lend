import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/data/models/loan.dart';
import 'package:nepal_lend/features/lending/data/lending_controller.dart';
import 'package:nepal_lend/features/lending/presentation/lending_ui.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class LenderPortfolioScreen extends ConsumerStatefulWidget {
  const LenderPortfolioScreen({super.key});

  @override
  ConsumerState<LenderPortfolioScreen> createState() =>
      _LenderPortfolioScreenState();
}

class _LenderPortfolioScreenState extends ConsumerState<LenderPortfolioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(lendingControllerProvider.notifier).loadStakes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lendingControllerProvider);
    final l10n = L10n.of(context);
    var active = 0;
    for (final stake in state.stakes) {
      if (stake.isActive) active += stake.amountPaisa;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.portfolioTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.yourStakesTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.activePrincipalText(formatNPRCompact(active)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              ScreenStateView(
                isLoading: state.busy && state.stakes.isEmpty,
                isEmpty: state.stakes.isEmpty,
                error: state.stakes.isEmpty ? state.error : null,
                onRetry: () => ref
                    .read(lendingControllerProvider.notifier)
                    .loadStakes(),
                emptyTitle: l10n.noStakesYet,
                emptyMessage: l10n.noStakesMessage,
                builder: (_) => ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.stakes.length,
                  itemBuilder: (context, index) => _StakeTile(
                    stake: state.stakes[index],
                    onTap: () =>
                        context.go('/stakes/${state.stakes[index].id}'),
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

class _StakeTile extends StatelessWidget {
  const _StakeTile({required this.stake, required this.onTap});

  final Stake stake;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stakeInLoanText(stake.loanId),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(formatNPRCompact(stake.amountPaisa)),
                ],
              ),
            ),
            StatusChip(
              label: stakeStatusLabel(context, stake.status),
              tone: stakeStatusTone(stake.status),
            ),
          ],
        ),
      ),
    );
  }
}
