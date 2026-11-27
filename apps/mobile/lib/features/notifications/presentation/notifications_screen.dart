import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/core/theme/app_theme.dart';
import 'package:nepal_lend/core/theme/ui.dart';
import 'package:nepal_lend/data/models/app_notification.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/notifications/data/notifications_controller.dart';
import 'package:nepal_lend/features/notifications/presentation/demo_tools_panel.dart';
import 'package:nepal_lend/l10n/l10n.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _timeLabels = <int, String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(notificationsControllerProvider.notifier).load();
    });
  }

  Future<void> _reload() =>
      ref.read(notificationsControllerProvider.notifier).load();

  Future<void> _open(AppNotification notification) async {
    await ref
        .read(notificationsControllerProvider.notifier)
        .markRead(notification.id);
    final route = notification.route;
    if (route != null && route.startsWith('/') && mounted) {
      context.go(route);
    }
  }

  String _timeLabel(DateTime createdAt) => _timeLabels.putIfAbsent(
        createdAt.millisecondsSinceEpoch,
        () => createdAt.toLocal().toString().split('.').first,
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final l10n = L10n.of(context);
    ref.listen(notificationEventsProvider, (_, _) {
      ref.read(notificationsControllerProvider.notifier).load();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
              onPressed: () =>
                  ref.read(notificationsControllerProvider.notifier).markAllRead(),
              child: Text(l10n.markAllReadButton),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.unreadCount == 0
                    ? l10n.allCaughtUpText
                    : l10n.unreadCountText(state.unreadCount),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              DemoToolsPanel(onChanged: _reload),
              const SizedBox(height: AppSpacing.md),
              ScreenStateView(
                isLoading: state.busy && state.items.isEmpty,
                isEmpty: state.items.isEmpty,
                error: state.error,
                onRetry: _reload,
                emptyTitle: l10n.noNotificationsYet,
                emptyMessage: l10n.noNotificationsMessage,
                builder: (_) => ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.items.length,
                  itemBuilder: (context, index) => _NotificationTile(
                    item: state.items[index],
                    timeLabel: _timeLabel(state.items[index].createdAt),
                    onOpen: _open,
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.timeLabel,
    required this.onOpen,
  });

  final AppNotification item;
  final String timeLabel;
  final Future<void> Function(AppNotification item) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        semanticsLabel: item.title,
        onTap: () => onOpen(item),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: Icon(_iconFor(item.type))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (item.isUnread)
                        StatusChip(
                          label: l10n.notificationNewChip,
                          tone: AppTone.warning,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(item.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    timeLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(NotificationType type) => switch (type) {
      NotificationType.kycApproved => Icons.verified_outlined,
      NotificationType.kycRejected => Icons.error_outline,
      NotificationType.loanFunded => Icons.account_balance_wallet_outlined,
      NotificationType.loanExpired => Icons.event_busy_outlined,
      NotificationType.paymentDue => Icons.schedule_outlined,
      NotificationType.paymentReceived => Icons.receipt_long_outlined,
      NotificationType.security => Icons.lock_outline,
    };
