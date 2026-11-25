import 'package:nepal_lend/data/models/enums.dart';

/// An in-app notification row. Track B delivers the same payload over FCM;
/// the demo publishes it to an in-process stream from [MockDb] writes.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.referenceId,
    this.route,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? referenceId;
  final String? route;

  bool get isRead => readAt != null;
  bool get isUnread => readAt == null;

  AppNotification copyWith({DateTime? readAt}) => AppNotification(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        readAt: readAt ?? this.readAt,
        referenceId: referenceId,
        route: route,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'type': type.name,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
        'referenceId': referenceId,
        'route': route,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String?;
    final type = NotificationType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => NotificationType.security,
    );
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: type,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      readAt: DateTime.tryParse(json['readAt'] as String? ?? ''),
      referenceId: json['referenceId'] as String?,
      route: json['route'] as String?,
    );
  }
}
