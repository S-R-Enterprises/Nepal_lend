import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/format_npr.dart';
import 'package:nepal_lend/features/notifications/presentation/notification_badge.dart';
import 'package:nepal_lend/features/repayments/data/repayment_controller.dart';
import 'package:nepal_lend/features/wallet/presentation/wallet_confirmation_sheet.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class RepaymentScreen extends ConsumerStatefulWidget {
  const RepaymentScreen({super.key, this.loanId});

  /// When omitted, the first repayable loan is selected.
  final String? loanId;

  @override
  ConsumerState<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends ConsumerState<RepaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(repaymentControllerProvider.notifier);
      final loanId = widget.loanId;
      if (loanId == null || loanId.isEmpty) {
        controller.loadAny();
      } else {
        controller.load(loanId);
      }
    });
  }

  void _review() {
    final state = ref.read(repaymentControllerProvider);
    if (state.next == null || state.loan == null) return;
    final l10n = L10n.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => WalletConfirmationSheet(
        title: l10n.confirmRepaymentTitle,
        amountPaisa: state.next!.totalPaisa,
        detail: l10n.repaymentSheetDetail(
          formatNPR(state.feePaisa),
          state.next!.number,
          _providerLabel(context, state.provider),
        ),
        confirmLabel: l10n.payInstalmentButton,
        onConfirm: () => _submit(state.loan!.id),
      ),
    );
  }

  Future<void> _submit(String loanId) async {
    Navigator.of(context).pop();
    final receipt = await ref
        .read(repaymentControllerProvider.notifier)
        .pay(loanId: loanId);
    if (!mounted || receipt == null) return;
    context.go('/wallet/transactions/${receipt.journalId}');
  }

  void _retry() {
    final loanId = widget.loanId;
    final controller = ref.read(repaymentControllerProvider.notifier);
    if (loanId == null || loanId.isEmpty) {
      controller.loadAny();
    } else {
      controller.load(loanId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repaymentControllerProvider);
    final l10n = L10n.of(context);
    final next = state.next;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.makeRepaymentTitle),
        actions: const [NotificationBadge()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.payOneAtATimeTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.repaymentSplitNote),
              const SizedBox(height: AppSpacing.lg),
              ScreenStateView(
                isLoading: state.busy && next == null,
                isEmpty: next == null,
                error: next == null ? state.error : null,
                onRetry: _retry,
                emptyTitle: l10n.nothingToRepayYet,
                emptyMessage: l10n.nothingToRepayMessage,
                builder: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildRepayment(context, state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRepayment(
    BuildContext context,
    RepaymentState state,
  ) {
    final l10n = L10n.of(context);
    final next = state.next!;
    return [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.instalmentProgressText(
                      next.number,
                      state.schedule.length,
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusChip(
                  label: _statusLabel(context, next.dueDate, state.busy),
                  tone: AppTone.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.dueDateText(
                next.dueDate.toLocal().toString().split(' ').first,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.amountToPayLabel),
            const SizedBox(height: AppSpacing.xs),
            AmountText(paisa: next.totalPaisa, large: true),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _row(l10n.principalLabel, next.principalPaisa),
            _row(l10n.interestLabel, next.interestPaisa),
            _row(l10n.platformFeeLabel, -state.feePaisa),
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _row(l10n.lendersReceiveLabel, next.totalPaisa - state.feePaisa),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.paymentMethodLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            initialValue: state.provider,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
            items: [
              DropdownMenuItem(
                value: 'esewa',
                child: Text(l10n.paymentProviderEsewaLabel),
              ),
              DropdownMenuItem(
                value: 'khalti',
                child: Text(l10n.paymentProviderKhaltiLabel),
              ),
            ],
            onChanged: (value) => ref
                .read(repaymentControllerProvider.notifier)
                .setProvider(value ?? 'esewa'),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      AppButton(
        label: l10n.payAmountButton(formatNPR(next.totalPaisa)),
        icon: Icons.payment_outlined,
        expand: true,
        loading: state.busy,
        onPressed: _review,
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(
        l10n.repaymentScheduleTitle,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: AppSpacing.sm),
      ...state.schedule.map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      item.isPaid ? AppColors.success : AppColors.surface,
                  child: Text(
                    '${item.number}',
                    style: TextStyle(
                      color: item.isPaid ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatNPR(item.totalPaisa)),
                      Text(
                        l10n.dueDateText(
                          item.dueDate.toLocal().toString().split(' ').first,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: item.isPaid
                      ? l10n.instalmentPaidChip
                      : l10n.instalmentDueChip,
                  tone: item.isPaid ? AppTone.success : AppTone.neutral,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _row(String label, int paisa) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              formatNPR(paisa),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );

  String _statusLabel(BuildContext context, DateTime dueDate, bool busy) {
    final l10n = L10n.of(context);
    if (busy) return l10n.repaymentStatusProcessing;
    return DemoClock.instance.now.isAfter(dueDate)
        ? l10n.repaymentStatusLate
        : l10n.repaymentStatusNextUp;
  }

  String _providerLabel(BuildContext context, String provider) {
    final l10n = L10n.of(context);
    return provider == 'khalti'
        ? l10n.providerLabelKhalti
        : l10n.providerLabelEsewa;
  }
}
