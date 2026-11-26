import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/data/models/app_notification.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/features/notifications/data/notification_event_bus.dart';

void main() {
  final receivedAt = DateTime.utc(2026, 11, 26, 12);

  test('FCM data payload is converted to an in-app notification row', () {
    final row = notificationFromRemoteMessage(
      RemoteMessage(
        messageId: 'fcm-1',
        data: <String, dynamic>{
          'id': 'note-1',
          'userId': 'user-1',
          'type': 'loanFunded',
          'title': 'Loan funded',
          'body': 'Your loan is ready',
          'referenceId': 'loan-1',
          'route': '/borrower/home',
        },
      ),
      receivedAt: receivedAt,
    );

    expect(row.id, 'note-1');
    expect(row.userId, 'user-1');
    expect(row.type, NotificationType.loanFunded);
    expect(row.title, 'Loan funded');
    expect(row.body, 'Your loan is ready');
    expect(row.createdAt, receivedAt);
    expect(row.referenceId, 'loan-1');
    expect(row.route, '/borrower/home');
    expect(row.isUnread, isTrue);
  });

  test('notification title wins over data title and unknown types fall back', () {
    final row = notificationFromRemoteMessage(
      RemoteMessage(
        messageId: 'fcm-2',
        notification: const RemoteNotification(
          title: 'From FCM',
          body: 'Body from FCM',
        ),
        data: <String, dynamic>{
          'title': 'From data',
          'body': 'Data body',
          'type': 'unknown-type',
        },
      ),
      receivedAt: receivedAt,
    );

    expect(row.id, 'fcm-2');
    expect(row.title, 'From FCM');
    expect(row.body, 'Body from FCM');
    expect(row.type, NotificationType.security);
  });

  test('publishRemote puts the converted row on the shared stream', () async {
    final future = NotificationEventBus.instance.events.first;
    NotificationEventBus.instance.publishRemote(
      RemoteMessage(
        messageId: 'fcm-3',
        data: <String, dynamic>{
          'userId': 'user-2',
          'type': 'paymentDue',
          'title': 'Payment due',
          'body': 'EMI is due tomorrow',
        },
      ),
    );

    final row = await future;
    expect(row, isA<AppNotification>());
    expect(row.id, 'fcm-3');
    expect(row.type, NotificationType.paymentDue);
  });
}
