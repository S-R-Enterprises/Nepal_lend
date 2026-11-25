import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/features/lending/data/lending_controller.dart';
import 'package:nepal_lend/features/lending/presentation/lending_ui.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class StakeDetailScreen extends ConsumerStatefulWidget {
  const StakeDetailScreen({super.key, required this.stakeId});

  final String stakeId;

  @override
  ConsumerState<StakeDetailScreen> createState() => _StakeDetailScreenState();
}

class _StakeDetailScreenState extends ConsumerState<StakeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(lendingControllerProvider.notifier).loadStake(widget.stakeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lendingControllerProvider);
    final l10n = L10n.of(context);
    final detail = state.currentStake?.stake.id == widget.stakeId
        ? state.currentStake
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stakeDetailsTitle)),
      body: SafeArea(
        child: ScreenStateView(
                isLoading: detail == null,
                isEmpty: false,
                error: state.error,
                onRetry: () => ref
                    .read(lendingControllerProvider.notifier)
                    .loadStake(widget.stakeId),
                builder: (_) => SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        StatusChip(
                          label: stakeStatusLabel(context, detail!.stake.status),
                          tone: stakeStatusTone(detail.stake.status),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.yourStakeTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AmountText(
                                  paisa: detail.stake.amountPaisa,
                                  large: true),
                              const SizedBox(height: AppSpacing.sm),
                              Text(l10n.stakeLoanLine(detail.loan.purpose)),
                              Text(
                                l10n.stakeBorrowerLine(
                                  borrowerLabel(context, detail.loan),
                                ),
                              ),
                              Text(
                                l10n.fundedOnDateText(
                                  _date(context, detail.stake.createdAt),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.ledgerTrailTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppButton(
                                label: l10n.viewFundingReceiptButton,
                                variant: AppButtonVariant.secondary,
                                expand: true,
                                onPressed: () => context.go(
                                  '/wallet/transactions/'
                                  '${detail.stake.fundingJournalId}',
                                ),
                              ),
                              if (detail.stake.reversalJournalId != null &&
                                  detail.stake.reversalJournalId!.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                AppButton(
                                  label: l10n.viewExpiryReversalButton,
                                  variant: AppButtonVariant.secondary,
                                  expand: true,
                                  onPressed: () => context.go(
                                    '/wallet/transactions/'
                                    '${detail.stake.reversalJournalId}',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (detail.stake.isReturned) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(l10n.stakeReturnedNote),
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
        ? l10n.unknownDateText
        : l10n.displayDate(date.day, date.month, date.year);
  }
}
