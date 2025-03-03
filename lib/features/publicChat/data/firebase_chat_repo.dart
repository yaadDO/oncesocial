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

    // Extract mentioned usernames and get their UIDs
    final mentionedUserIds = await _getMentionedUserIds(text);

    await _firestore.collection('messages').add({
      'text': text,
      'senderId': user.uid,
      'senderName': _cachedSenderName!,
      'timestamp': FieldValue.serverTimestamp(),
      'localTimestamp': DateTime.now().millisecondsSinceEpoch,
      'mentionedUserIds': mentionedUserIds, // Add this field
    });
  }

  Future<List<String>> _getMentionedUserIds(String text) async {
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(text);
    final usernames = matches.map((m) => m.group(1)).toSet().toList();

    final List<String> userIds = [];
    for (final username in usernames) {
      final query = await _firestore
          .collection('users')
          .where('name', isEqualTo: username)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        userIds.add(query.docs.first.id);
      }
    }
    return userIds;
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}