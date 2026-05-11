import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/remote/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>> getNotifications({int pageIndex = 1, int pageSize = 20}) async {
    return await remoteDataSource.getNotifications(pageIndex: pageIndex, pageSize: pageSize);
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    return await remoteDataSource.markAsRead(notificationId);
  }
}
