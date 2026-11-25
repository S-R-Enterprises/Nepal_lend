import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nepal_lend/features/notifications/data/notifications_controller.dart';
import 'package:nepal_lend/l10n/l10n.dart';

/// App-bar action showing the live unread count. Mock FCM events refresh the
/// inbox automatically so the badge cannot go stale during a demo.
class NotificationBadge extends ConsumerStatefulWidget {
  const NotificationBadge({super.key});

  @override
  ConsumerState<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends ConsumerState<NotificationBadge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(notificationsControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(notificationsControllerProvider).unreadCount;
    final l10n = L10n.of(context);
    ref.listen(notificationEventsProvider, (_, _) {
      ref.read(notificationsControllerProvider.notifier).load();
    });

    return IconButton(
      tooltip: l10n.notificationsTooltip,
      onPressed: () => context.go('/notifications'),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(l10n.unreadCountBadge(count)),
        child: const Icon(Icons.notifications_none),
      ),
    );
  }
}
