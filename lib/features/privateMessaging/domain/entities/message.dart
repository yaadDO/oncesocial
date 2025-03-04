import 'package:cloud_firestore/cloud_firestore.dart';

class MessagePrivate {
  final String id;
  final String senderId;
  final String receiverId;
  final String messagepriv;
  final DateTime timestamp;
  final String chatRoomId;
  final bool read;

  MessagePrivate({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.messagepriv,
    required this.timestamp,
    required this.chatRoomId,
    this.read = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'messagepriv': messagepriv,
      'timestamp': timestamp,
      'chatRoomId': chatRoomId,
      'read': read,
    };
  }

  factory MessagePrivate.fromMap(Map<String, dynamic> map, String id) {
    return MessagePrivate(
      id: id,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      messagepriv: map['messagepriv'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      chatRoomId: map['chatRoomId'],
      read: map['read'] ?? false,
    );
  }
}