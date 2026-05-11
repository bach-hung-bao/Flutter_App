import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> execute({int pageIndex = 1, int pageSize = 20}) {
    return repository.getNotifications(pageIndex: pageIndex, pageSize: pageSize);
  }
}

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;
  MarkNotificationAsReadUseCase(this.repository);

  Future<void> execute(int notificationId) {
    return repository.markAsRead(notificationId);
  }
}
