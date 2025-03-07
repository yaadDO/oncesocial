// notifications/presentation/cubits/notification_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/firebase_notification_repo.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final FirebaseNotificationRepo _repo;
  StreamSubscription? _notificationSub;

  NotificationCubit(this._repo) : super(NotificationInitial()) {
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationSub = _repo.getNotifications().listen((notifications) {
      emit(NotificationsLoaded(notifications));
    }, onError: (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _repo.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
  }

  @override
  Future<void> close() {
    _notificationSub?.cancel();
    return super.close();
  }
}