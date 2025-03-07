// notifications/presentation/cubits/notification_state.dart
import '../../domain/entities/notification.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<AppNotification> notifications;

  NotificationsLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}