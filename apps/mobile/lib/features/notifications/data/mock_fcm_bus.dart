import 'package:nepal_lend/features/notifications/data/notification_event_bus.dart';

/// Backwards-compatible name for the notification stream.
@Deprecated('Use NotificationEventBus instead.')
class MockFcmBus {
  MockFcmBus._();

  static NotificationEventBus get instance => NotificationEventBus.instance;
}
