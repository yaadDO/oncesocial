import 'package:cloud_firestore/cloud_firestore.dart';

class MessagePrivate {
  final String senderId;
  final String receiverId;
  final String messagepriv;
  final DateTime timestamp;
  final String chatRoomId;

  MessagePrivate({
    required this.senderId,
    required this.receiverId,
    required this.messagepriv,
    required this.timestamp,
    required this.chatRoomId,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'messagepriv': messagepriv,
      'timestamp': timestamp,
      'chatRoomId': chatRoomId,
    };
  }

  factory MessagePrivate.fromMap(Map<String, dynamic> map) {
    return MessagePrivate(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      messagepriv: map['messagepriv'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      chatRoomId: map['chatRoomId'],
    );
  }
}