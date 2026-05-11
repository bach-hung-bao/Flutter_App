import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications({int pageIndex = 1, int pageSize = 20});
  Future<void> markAsRead(int notificationId);
}
