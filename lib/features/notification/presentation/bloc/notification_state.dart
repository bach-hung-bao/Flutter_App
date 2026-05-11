import '../../domain/entities/notification_entity.dart';

class NotificationState {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String error;
  final int pageIndex;
  final int pageSize;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.error = '',
    this.pageIndex = 1,
    this.pageSize = 20,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? error,
    int? pageIndex,
    int? pageSize,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error ?? this.error,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
