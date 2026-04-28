import '../entities/notification_entity.dart';
import '../../data/notification_api_service.dart';

class GetNotificationsUseCase {
  final NotificationApiService _apiService;

  GetNotificationsUseCase(this._apiService);

  Future<List<NotificationEntity>> execute({
    int pageIndex = 1,
    int pageSize = 20,
  }) {
    return _apiService.getNotifications(
      pageIndex: pageIndex,
      pageSize: pageSize,
    );
  }
}
