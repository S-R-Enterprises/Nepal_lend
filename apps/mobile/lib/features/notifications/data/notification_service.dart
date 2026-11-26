import 'package:nepal_lend/core/utils/demo_clock.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_notification.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/notifications/data/notification_event_bus.dart';
import 'package:uuid/uuid.dart';

/// Writes notification rows and emits the matching mock FCM event. Every
/// producer (KYC, funding, repayment, jobs) goes through this boundary so the
/// badge count and the notification inbox cannot disagree.
class NotificationService {
  NotificationService(this._db);

  final MockDb _db;

  Future<AppNotification> notify({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? id,
    String? referenceId,
    String? route,
    DateTime? now,
  }) async {
    final notification = AppNotification(
      id: id ?? 'notif-${const Uuid().v4()}',
      userId: userId,
      type: type,
      title: title,
      body: body,
      createdAt: now ?? DemoClock.instance.now,
      referenceId: referenceId,
      route: route,
    );
    await _db.setNotification(notification);
    NotificationEventBus.instance.publish(notification);
    return notification;
  }

  Future<int> markRead(String id, {DateTime? now}) =>
      _db.markNotificationRead(id, now: now);

  Future<int> markAllRead(String userId, {DateTime? now}) =>
      _db.markAllNotificationsRead(userId, now: now);
}
