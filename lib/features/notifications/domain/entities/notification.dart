// notifications/domain/entities/notification.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type;
  final String userId;
  final String senderId;
  final String senderName;
  final String messageText;
  final DateTime timestamp;
  final bool read;
  final String messageId;

  AppNotification({
    required this.id,
    required this.type,
    required this.userId,
    required this.senderId,
    required this.senderName,
    required this.messageText,
    required this.timestamp,
    required this.read,
    required this.messageId,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      type: data['type'] ?? '',
      userId: data['userId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Anonymous',
      messageText: data['messageText'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      read: data['read'] ?? false,
      messageId: data['messageId'] ?? '',
    );
  }
}