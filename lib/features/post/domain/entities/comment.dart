//Defines a Comment model for use in app that interacts with Firebase Firestore

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId; //id of post that comment belongs to
  final String userId; //id of comment poster
  final String userName; //Comment posters username
  final String text;
  final DateTime timestamp;

  //constructor, create instances
  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });

  //Converts the Comment object to a JSON-like Map format, which can be stored in Firestore.
  Map<String, dynamic> toJson () {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp':Timestamp.fromDate(timestamp),
    };
  }

  //factory keyword: used to define a constructor that doesn’t always create a new instance of the class,
  //Instead, it can return an existing instance, a subclass, or a completely different object, Cant Access this
  //The fromJson factory constructor is used to convert Firestore data back into a Dart object.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      userName: json['userName'],
      text: json['text'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
