import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/data/models/app_notification.dart';
import 'package:nepal_lend/features/notifications/data/mock_fcm_bus.dart';

/// Notification boundary. Track B keeps the same inbox contract while FCM
/// delivers the upstream event instead of the in-process mock stream.
abstract class NotificationsRepository {
  Future<List<AppNotification>> mine();

  Future<int> markRead(String id);

  Future<int> markAllRead();

  Stream<AppNotification> get events;
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return MockNotificationsRepository(api: ref.watch(apiClientProvider));
});

class MockNotificationsRepository implements NotificationsRepository {
  const MockNotificationsRepository({required this.api});

  final ApiClient api;

  @override
  Future<List<AppNotification>> mine() async {
    final response = await api.getJson('/notifications');
    return (response['items'] as List<dynamic>)
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<int> markRead(String id) async {
    final response = await api.postJson('/notifications/$id/read');
    return (response['changed'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<int> markAllRead() async {
    final response = await api.postJson('/notifications/read-all');
    return (response['changed'] as num?)?.toInt() ?? 0;
  }

  @override
  Stream<AppNotification> get events => MockFcmBus.instance.events;
}
