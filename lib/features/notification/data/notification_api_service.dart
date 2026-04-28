import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../domain/entities/notification_entity.dart';

class NotificationApiService {
  final ApiClient _client;
  final AuthStorage _authStorage = AuthStorage();

  NotificationApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<NotificationEntity>> getNotifications({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final token = await _authStorage.getAccessToken();
    final response = await _client.get(
      '/api/notifications',
      query: {'pageIndex': pageIndex, 'pageSize': pageSize},
      accessToken: token,
    );

    // Check if the structure contains "data" array or it's directly an array
    final data = response['data'] ?? response;
    if (data is! List) return <NotificationEntity>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(NotificationEntity.fromJson)
        .toList();
  }

  Future<void> markAsRead(int notificationId) async {
    final token = await _authStorage.getAccessToken();
    await _client.put(
      '/api/notifications/$notificationId',
      accessToken: token,
      body: {'isRead': true},
    );
  }
}
