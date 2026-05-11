import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/notification_usecases.dart';
import '../../domain/entities/notification_entity.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotifications;
  final MarkNotificationAsReadUseCase markNotificationAsRead;

  NotificationBloc({
    required this.getNotifications,
    required this.markNotificationAsRead,
  }) : super(const NotificationState()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<LoadMoreNotificationsEvent>(_onLoadMoreNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
  }

  Future<void> _onLoadNotifications(
      LoadNotificationsEvent event, Emitter<NotificationState> emit) async {
    if (event.reset) {
      emit(state.copyWith(
        notifications: [],
        pageIndex: 1,
        hasReachedMax: false,
        error: '',
        isLoading: true,
      ));
    } else {
      emit(state.copyWith(isLoading: true, error: ''));
    }

    try {
      final items = await getNotifications.execute(
        pageIndex: state.pageIndex,
        pageSize: state.pageSize,
      );
      emit(state.copyWith(
        notifications: event.reset ? items : [...state.notifications, ...items],
        hasReachedMax: items.length < state.pageSize,
        isLoading: false,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
        isLoadingMore: false,
      ));
    }
  }

  Future<void> _onLoadMoreNotifications(
      LoadMoreNotificationsEvent event, Emitter<NotificationState> emit) async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(
      isLoadingMore: true,
      pageIndex: state.pageIndex + 1,
    ));

    try {
      final items = await getNotifications.execute(
        pageIndex: state.pageIndex,
        pageSize: state.pageSize,
      );
      emit(state.copyWith(
        notifications: [...state.notifications, ...items],
        hasReachedMax: items.length < state.pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
      ));
    }
  }

  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsReadEvent event, Emitter<NotificationState> emit) async {
    try {
      await markNotificationAsRead.execute(event.notificationId);
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == event.notificationId) {
          return NotificationEntity(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            isRead: true, // Lạc quan
            createdAt: n.createdAt,
            type: n.type,
          );
        }
        return n;
      }).toList();
      emit(state.copyWith(notifications: updatedNotifications));
    } catch (e) {
      // Bỏ qua nếu lỗi
    }
  }
}
