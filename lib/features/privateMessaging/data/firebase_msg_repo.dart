import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/message.dart';
import '../domain/repositories/message_repo.dart';

class FirebaseMsgRepo implements MsgRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> sendMessage(MessagePrivate message) async {
    await _firestore.collection('messagesprivate').add(message.toMap());
  }

  @override
  Stream<List<MessagePrivate>> getMessages(String chatRoomId) {
    return _firestore
        .collection('messagesprivate')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessagePrivate.fromMap(doc.data(), doc.id))
        .toList());
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messagesprivate').doc(messageId).delete();
  }
}