import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.entityType,
    this.entityId,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String? entityType;
  final String? entityId;
  final String? readAt;
  final String createdAt;

  bool get isUnread => readAt == null;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}

final notificationsListProvider =
    FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
  final dio = ref.watch(apiClientProvider).dio;
  final res = await dio.get<Map<String, dynamic>>(
    ApiEndpoints.notifications,
    queryParameters: const {'limit': 50},
  );
  final items = res.data?['items'] as List<dynamic>? ?? [];
  return items
      .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
      .toList();
});

final unreadNotificationsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final dio = ref.watch(apiClientProvider).dio;
  final res = await dio.get<Map<String, dynamic>>(
    ApiEndpoints.notificationsUnreadCount,
  );
  return (res.data?['count'] as num?)?.toInt() ?? 0;
});

Future<void> markNotificationRead(WidgetRef ref, String id) async {
  final dio = ref.read(apiClientProvider).dio;
  await dio.patch(ApiEndpoints.notificationRead(id));
  ref.invalidate(notificationsListProvider);
  ref.invalidate(unreadNotificationsCountProvider);
}

Future<void> markAllNotificationsRead(WidgetRef ref) async {
  final dio = ref.read(apiClientProvider).dio;
  await dio.patch(ApiEndpoints.notificationsReadAll);
  ref.invalidate(notificationsListProvider);
  ref.invalidate(unreadNotificationsCountProvider);
}
