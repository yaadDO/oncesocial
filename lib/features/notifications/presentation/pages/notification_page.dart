// notifications/presentation/pages/notification_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../cubits/notification_cubit.dart';
import '../cubits/notification_state.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            tooltip: l10n.markAllRead,
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(child: Text(state.message));
          }
          final notifications = (state as NotificationsLoaded).notifications;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.read
                      ? Colors.grey
                      : Colors.red,
                  child: const Icon(Icons.notifications, color: Colors.white),
                ),
                title: Text(notification.senderName),
                subtitle: Text(notification.messageText),
                trailing: Text(
                  DateFormat('MMM dd, HH:mm', 'es').format(notification.timestamp),
                ),
                onTap: () {
                  context.read<NotificationCubit>().markAsRead(notification.id);
                  Navigator.pushNamed(
                    context,
                    '/ChatPage',
                    arguments: notification.messageId,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}