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
    // Use localTimestamp to ensure messages show immediately
        .orderBy('localTimestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final messages = <Message>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Optionally include the document id if needed:
        data['id'] = doc.id;
        final userProfile = await _profileRepo.fetchUserProfile(data['senderId']);
        messages.add(Message.fromMap({
          ...data,
          'senderName': userProfile?.name ?? 'Anonymous',
        }));
      }
      return messages;
    });
  }

  @override
  Future<void> sendMessage(String text) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final userProfile = await _profileRepo.fetchUserProfile(user.uid);

    await _firestore.collection('messages').add({
      'text': text,
      'senderId': user.uid,
      'senderName': userProfile?.name ?? 'Anonymous',
      // Server timestamp (will be null locally at first)
      'timestamp': FieldValue.serverTimestamp(),
      // Local timestamp (always set immediately)
      'localTimestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}