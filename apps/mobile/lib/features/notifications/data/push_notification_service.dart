import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nepal_lend/features/notifications/data/notification_event_bus.dart';

const String pushChannelId = 'nepallend_updates';

/// Owns FCM permission, token registration and foreground notification display.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  String? _lastToken;
  bool _foregroundInitialized = false;
  bool _localInitialized = false;

  Stream<String> get tokens => _tokenController.stream;

  Future<String?> get currentToken async => _lastToken;

  /// Called once from `main()` after Firebase.initializeApp().
  Future<void> initializeForeground() async {
    if (_foregroundInitialized) return;
    _foregroundInitialized = true;
    await _initializeLocalNotifications();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final allowed = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (allowed) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onMessage.listen((message) {
      NotificationEventBus.instance.publishRemote(message);
      unawaited(show(message));
    });
    FirebaseMessaging.onMessageOpenedApp.listen(
      NotificationEventBus.instance.publishRemote,
    );

    // Listen before registering so the initial registration is not missed.
    _messaging.onRegistered.listen(_emitToken);
    await _messaging.register();
  }

  /// Background isolate setup. Listeners are intentionally not registered.
  Future<void> initializeBackground() async {
    await _initializeLocalNotifications();
  }

  Future<void> show(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String? ?? '';
    final body = notification?.body ?? message.data['body'] as String? ?? '';
    if (title.isEmpty && body.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      pushChannelId,
      'NepalLend updates',
      channelDescription: 'Loan, payment and verification updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    final id = int.tryParse(message.data['notificationId'] as String? ?? '') ??
        DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: message.data['route'] as String?,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localInitialized) return;
    _localInitialized = true;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(settings: settings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            pushChannelId,
            'NepalLend updates',
            description: 'Loan, payment and verification updates',
            importance: Importance.high,
          ),
        );
  }

  void _emitToken(String token) {
    _lastToken = token;
    if (!_tokenController.isClosed) _tokenController.add(token);
  }
}
