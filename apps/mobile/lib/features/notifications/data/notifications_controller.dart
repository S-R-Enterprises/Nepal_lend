import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/models/app_notification.dart';
import 'package:nepal_lend/data/repositories/notifications_repository.dart';
import 'package:nepal_lend/features/kyc/data/kyc_gate.dart';

class NotificationsState {
  const NotificationsState({
    this.items = const <AppNotification>[],
    this.unreadCount = 0,
    this.busy = false,
    this.error,
  });

  final List<AppNotification> items;
  final int unreadCount;
  final bool busy;
  final String? error;

  NotificationsState copyWith({
    List<AppNotification>? items,
    int? unreadCount,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      NotificationsState(
        items: items ?? this.items,
        unreadCount: unreadCount ?? this.unreadCount,
        busy: busy ?? this.busy,
        error: clearError ? null : error ?? this.error,
      );
}

/// Inbox state. Auth/KYC is enforced here as well as in the adapter so a stale
/// widget cannot read another user's notifications.
class NotificationsController extends Notifier<NotificationsState> {
  @override
  NotificationsState build() => const NotificationsState();

  NotificationsRepository get _repository =>
      ref.read(notificationsRepositoryProvider);

  void _requireUser() => ref.read(requireVerifiedUserProvider)();

  Future<void> load() async {
    try {
      _requireUser();
      state = state.copyWith(busy: true, clearError: true);
      final items = await _repository.mine();
      state = state.copyWith(
        items: items,
        unreadCount: items.where((item) => item.isUnread).length,
        busy: false,
        clearError: true,
      );
    } on AppFailure catch (failure) {
      state = state.copyWith(busy: false, error: failure.message);
    }
  }

  Future<void> markRead(String id) async {
    try {
      _requireUser();
      final changed = await _repository.markRead(id);
      if (changed == 0) return;
      final items = state.items
          .map((item) => item.id == id ? item.copyWith(readAt: DemoClock.instance.now) : item)
          .toList(growable: false);
      state = state.copyWith(
        items: items,
        unreadCount: items.where((item) => item.isUnread).length,
      );
    } on AppFailure catch (failure) {
      state = state.copyWith(error: failure.message);
    }
  }

  Future<void> markAllRead() async {
    try {
      _requireUser();
      await _repository.markAllRead();
      final now = DemoClock.instance.now;
      final items = state.items
          .map((item) => item.isUnread ? item.copyWith(readAt: now) : item)
          .toList(growable: false);
      state = state.copyWith(items: items, unreadCount: 0);
    } on AppFailure catch (failure) {
      state = state.copyWith(error: failure.message);
    }
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
  NotificationsController.new,
);

/// Local and FCM notification events. Screens listen to refresh the inbox/badge.
final notificationEventsProvider = StreamProvider<AppNotification>((ref) {
  return ref.watch(notificationsRepositoryProvider).events;
});
