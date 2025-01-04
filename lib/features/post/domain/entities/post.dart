//Defines a Post model to interact with Firebase Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'comment.dart';

class Post {
  final String id;
  final String userId; //post creator
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;

  //constructor
  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  //Creates a copy of the current Post object, allowing only the imageUrl to be updated
  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
    );
  }

  //Converts the Post object into a JSON-like Map that can be stored in Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      //Converts each Comment object into a JSON-like Map by calling its toJson method.
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    //extracts the list of comments if it exists, otherwise assigns null
    final List<Comment> comments = (json['comments'] as List<dynamic>?)
    ?.map((commentJson) => Comment.fromJson(commentJson))
    .toList() ?? [];

    return Post(
      id: json['id'],
      userId: json['userId'],
      userName: json['name'],
      text: json['text'],
      imageUrl: json['imageUrl'],
      //Converts the Firestore Timestamp back into a Dart DateTime object.
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      //Converts the likes field into a list of strings. If the likes field is missing or null
      likes: List<String>.from(json['likes'] ?? []),
      comments: comments,
    );
  }

}
