import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../profile/data/firebase_profile_repo.dart';
import '../domain/entities/message.dart';
import '../domain/repos/chat_repo.dart';

class FirebaseChatRepo implements ChatRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseProfileRepo _profileRepo;

  FirebaseChatRepo({required FirebaseProfileRepo profileRepo})
      : _profileRepo = profileRepo;

  @override
  Stream<List<Message>> getMessages() {
    return _firestore
        .collection('messages')
        .orderBy('localTimestamp', descending: true).limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID
        return Message.fromMap(data);
      }).toList();
    });
  }

  String? _cachedSenderName;

  @override
  Future<void> sendMessage(String text) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    if (_cachedSenderName == null) {
      final userProfile = await _profileRepo.fetchUserProfile(user.uid);
      _cachedSenderName = userProfile?.name ?? 'Anonymous';
    }

    await _firestore.collection('messages').add({
      'text': text,
      'senderId': user.uid,
      'senderName': _cachedSenderName!,
      'timestamp': FieldValue.serverTimestamp(),
      'localTimestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}