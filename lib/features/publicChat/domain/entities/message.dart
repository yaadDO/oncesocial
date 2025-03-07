import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id; //Unique identifier for the message.
  final String text; //The content of the message.
  final String senderId; //ID of the user who sent the message
  final String senderName; //The name of the user who sent the message.
  final DateTime? timestamp; //Will be null until the server returns a timestamp(nullable until the server provides it).
  final DateTime localTimestamp; //Always set on sending, Client Generated

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.localTimestamp,
    this.timestamp,
  });

  // Converts a Map<String, dynamic> from firestore into a Message object.
  //Handles nullable fields like timestamp and provides default values
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

  //Converts a Message object into a Map<String, dynamic> for saving to Firestore
  //Maps the properties of the Message object to key-value pairs.
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
