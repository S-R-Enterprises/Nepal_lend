import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/demo_ui_state.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/repositories/repayment_repository.dart';
import 'package:nepal_lend/l10n/l10n.dart';

/// Mock-only controls for the demo clock, scheduled jobs and UI states.
///
/// Fast-forwarding updates [DemoClock] (used by due dates, receipts and jobs),
/// then the job buttons generate the matching notifications so the whole
/// repayment timeline can be walked in seconds. The state switcher lets a
/// reviewer inspect loading/empty/error/offline screens without a backend.
/// Track B hides this panel and uses trusted server time plus real schedulers.
class DemoToolsPanel extends ConsumerWidget {
  const DemoToolsPanel({super.key, required this.onChanged});

  /// Called after a job runs so the inbox and badge refresh immediately.
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(envProvider).isMock) return const SizedBox.shrink();
    final repository = ref.read(repaymentRepositoryProvider);
    final l10n = L10n.of(context);

    Future<void> runJob(Future<String> Function() action) async {
      try {
        final message = await action();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        await onChanged();
      } on AppFailure catch (failure) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      }
    }

    return ValueListenableBuilder<Duration>(
      valueListenable: DemoClock.instance.offset,
      builder: (context, offset, _) {
        final date = DemoClock.instance.now.toLocal().toString().split('.').first;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const ExcludeSemantics(
                    child: Icon(Icons.schedule_outlined, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.demoClockLabel(date),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _DemoClockButton(
                    label: l10n.clockAdvanceOneDay,
                    duration: const Duration(days: 1),
                  ),
                  _DemoClockButton(
                    label: l10n.clockAdvanceSevenDays,
                    duration: const Duration(days: 7),
                  ),
                  _DemoClockButton(
                    label: l10n.clockAdvanceOneMonth,
                    duration: const Duration(days: 30),
                  ),
                  AppButton(
                    label: l10n.clockResetButton,
                    variant: AppButtonVariant.text,
                    onPressed: () => DemoClock.instance.reset(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.demoStateTitle,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _DemoStateButton(
                    label: l10n.demoStateNormal,
                    state: DemoUiState.normal,
                    ref: ref,
                  ),
                  _DemoStateButton(
                    label: l10n.demoStateLoading,
                    state: DemoUiState.loading,
                    ref: ref,
                  ),
                  _DemoStateButton(
                    label: l10n.demoStateEmpty,
                    state: DemoUiState.empty,
                    ref: ref,
                  ),
                  _DemoStateButton(
                    label: l10n.demoStateError,
                    state: DemoUiState.error,
                    ref: ref,
                  ),
                  _DemoStateButton(
                    label: l10n.demoStateOffline,
                    state: DemoUiState.offline,
                    ref: ref,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  AppButton(
                    label: l10n.demoRemindersButton,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => runJob(() async {
                      final sent = await repository.sendReminders();
                      return l10n.paymentRemindersSentSnackbar(sent);
                    }),
                  ),
                  AppButton(
                    label: l10n.demoMarkOverdueButton,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => runJob(() async {
                      final changed = await repository.markOverdue();
                      return l10n.loansMarkedOverdueSnackbar(changed);
                    }),
                  ),
                  AppButton(
                    label: l10n.demoReconcileButton,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => runJob(() async {
                      final result = await repository.reconcile();
                      return result.isClean
                          ? l10n.ledgerCleanSnackbar(result.journalsChecked)
                          : l10n.ledgerIssuesSnackbar(
                              result.negativeWalletAccounts.length,
                              result.unbalancedJournalIds.length,
                            );
                    }),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}

class _DemoClockButton extends StatelessWidget {
  const _DemoClockButton({required this.label, required this.duration});

  final String label;
  final Duration duration;

  @override
  Widget build(BuildContext context) => AppButton(
        label: label,
        variant: AppButtonVariant.secondary,
        onPressed: () => DemoClock.instance.advance(duration),
      );
}

class _DemoStateButton extends StatelessWidget {
  const _DemoStateButton({
    required this.label,
    required this.state,
    required this.ref,
  });

  final String label;
  final DemoUiState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => AppButton(
        label: label,
        variant: AppButtonVariant.text,
        onPressed: () => ref.read(demoUiStateProvider.notifier).select(state),
      );
}
