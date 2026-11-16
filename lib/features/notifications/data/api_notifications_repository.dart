import '../../../core/network/api_client.dart';
import '../domain/app_notification.dart';
import 'notifications_repository.dart';

/// Notifications branchées sur le back JOYN.
///
/// - `GET    /api/v1/notifications?page&limit`
/// - `PATCH  /api/v1/notifications/{id}/read`
/// - `PATCH  /api/v1/notifications/read-all`
/// - `DELETE /api/v1/notifications/{id}`
/// - `DELETE /api/v1/notifications/read`
class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._api);

  final ApiClient _api;

  static const String basePath = '/api/v1/notifications';

  @override
  Future<NotificationPage> fetch({int limit = 30}) async {
    final json = await _api.getJson(
      basePath,
      query: {'page': '1', 'limit': '${limit.clamp(1, 50)}'},
    );
    final root = _asMap(json);
    final body = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;
    final items = body['notifications'] ?? body['items'] ?? body['content'];
    return NotificationPage(
      items: (items is List ? items : const [])
          .map((e) => map(_asMap(e)))
          .toList(),
      unreadCount: _int(body['unreadCount'] ?? body['unread_count']),
    );
  }

  @override
  Future<void> markRead(String id) async {
    await _api.patchJson('$basePath/$id/read');
  }

  @override
  Future<void> markAllRead() async {
    await _api.patchJson('$basePath/read-all');
  }

  @override
  Future<void> delete(String id) async {
    await _api.deleteJson('$basePath/$id');
  }

  @override
  Future<int> deleteRead() async {
    final json = await _api.deleteJson('$basePath/read');
    return _int(_asMap(json)['affectedCount']);
  }

  /// Convertit un `NotificationItem` du back.
  static AppNotification map(Map<String, dynamic> json) {
    final link = json['link']?.toString().trim();
    return AppNotification(
      id: '${json['id']}',
      kind: NotificationKind.fromApi(json['type']?.toString()),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      link: link == null || link.isEmpty ? null : link,
      isRead: json['isRead'] == true || json['is_read'] == true,
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? json['created_at']}')
              ?.toLocal() ??
          DateTime.now(),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static int _int(Object? value) => switch (value) {
    int v => v,
    num v => v.round(),
    String v => int.tryParse(v) ?? 0,
    _ => 0,
  };
}
