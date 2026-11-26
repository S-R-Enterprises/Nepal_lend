import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nepal_lend/data/models/app_notification.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:uuid/uuid.dart';

/// Single stream consumed by the notification inbox and unread badge.
///
/// Local producers publish here directly. FCM messages are converted to the
/// same [AppNotification] shape, so screens never depend on the transport.
class NotificationEventBus {
  NotificationEventBus._();

  static final NotificationEventBus instance = NotificationEventBus._();

  final StreamController<AppNotification> _controller =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get events => _controller.stream;

  void publish(AppNotification notification) {
    if (!_controller.isClosed) _controller.add(notification);
  }

  void publishRemote(RemoteMessage message) =>
      publish(notificationFromRemoteMessage(message));
}

/// Converts an FCM payload into the same row shape as local notifications.
AppNotification notificationFromRemoteMessage(
  RemoteMessage message, {
  DateTime? receivedAt,
}) {
  final data = message.data;
  return AppNotification(
    id: data['id'] as String? ?? message.messageId ?? const Uuid().v4(),
    userId: data['userId'] as String? ?? '',
    type: notificationTypeFromString(data['type'] as String?),
    title: message.notification?.title ?? data['title'] as String? ?? '',
    body: message.notification?.body ?? data['body'] as String? ?? '',
    createdAt: receivedAt ?? DateTime.now(),
    referenceId: data['referenceId'] as String?,
    route: data['route'] as String?,
  );
}

NotificationType notificationTypeFromString(String? raw) {
  if (raw == null) return NotificationType.security;
  for (final value in NotificationType.values) {
    if (value.name == raw) return value;
  }
  return NotificationType.security;
}
