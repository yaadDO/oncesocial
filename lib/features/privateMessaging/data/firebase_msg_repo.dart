import 'package:cloud_firestore/cloud_firestore.dart';
import '../../profile/domain/entities/profile_user.dart';
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

  Future<List<ProfileUser>> fetchUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    return query.docs.map((doc) => ProfileUser.fromJson(doc.data())).toList();
  }
  @override
  Stream<int> getUnreadCount(String receiverId, String senderId) {
    return _firestore
        .collection('messagesprivate')
        .where('receiverId', isEqualTo: receiverId)
        .where('senderId', isEqualTo: senderId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    await _firestore.collection('messagesprivate').doc(messageId).update({'read': true});
  }
}