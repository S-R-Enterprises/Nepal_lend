import 'dart:async';

import 'package:nepal_lend/data/models/app_notification.dart';

/// In-process stand-in for FCM. Track B replaces this with a real push token
/// registration and upstream topic messages; the UI contract stays the same.
class MockFcmBus {
  MockFcmBus._();

  static final MockFcmBus instance = MockFcmBus._();

  final StreamController<AppNotification> _controller =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get events => _controller.stream;

  void publish(AppNotification notification) {
    if (!_controller.isClosed) _controller.add(notification);
  }
}
