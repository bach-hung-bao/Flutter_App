abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotificationsEvent extends NotificationEvent {
  final bool reset;
  const LoadNotificationsEvent({this.reset = false});
}

class LoadMoreNotificationsEvent extends NotificationEvent {
  const LoadMoreNotificationsEvent();
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final int notificationId;
  const MarkNotificationAsReadEvent(this.notificationId);
}
