import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime? timestamp; // Will be null until the server returns a timestamp
  final DateTime localTimestamp; // Always set on sending

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.localTimestamp,
    this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Anonymous',
      // If the server timestamp hasn't come through yet, this remains null.
      timestamp: map['timestamp'] != null ? (map['timestamp'] as Timestamp).toDate() : null,
      // Convert localTimestamp from int (milliseconds) to DateTime
      localTimestamp: DateTime.fromMillisecondsSinceEpoch(map['localTimestamp'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp,
      'localTimestamp': localTimestamp.millisecondsSinceEpoch,
    };
  }
}
