import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/features/auth/data/auth_controller.dart';
import 'package:nepal_lend/features/auth/data/auth_repository.dart';
import 'package:nepal_lend/features/notifications/data/push_notification_service.dart';

/// Keeps the backend device-token row in sync with the signed-in Firebase user.
final pushRegistrationProvider = Provider<PushNotificationService>((ref) {
  final service = PushNotificationService.instance;
  if (Firebase.apps.isEmpty) return service;

  final repository = ref.read(authRepositoryProvider);

  Future<void> register(String token) async {
    if (!ref.read(authProvider).isSignedIn) return;
    try {
      await repository.saveDeviceToken(token);
    } catch (_) {
      // Token registration is best effort; it must not block the auth flow.
    }
  }

  final subscription = service.tokens.listen((token) => unawaited(register(token)));
  ref.listen<AuthState>(authProvider, (_, state) async {
    if (!state.isSignedIn) return;
    final token = await service.currentToken;
    if (token != null) await register(token);
  });
  ref.onDispose(subscription.cancel);
  return service;
});
