import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/data/firebase_profile_repo.dart';
import '../domain/entities/message.dart';
import '../domain/repos/chat_repo.dart';

class FirebaseChatRepo implements ChatRepo {
  //Instance of Firestore for database operations.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseProfileRepo _profileRepo;

  FirebaseChatRepo({required FirebaseProfileRepo profileRepo})
      : _profileRepo = profileRepo;

  @override
  Stream<List<Message>> getMessages() {
    return _firestore
        .collection('messages')
        .orderBy('localTimestamp', descending: true).limit(100) //Limits the results to 100 messages.
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>; //Returns Stream<List<Message>> for real-time updates.
        data['id'] = doc.id;
        return Message.fromMap(data);
      }).toList();
    });
  }

  String? _cachedSenderName;

  //Sends a new message to the Firestore messages collection.
  @override
  Future<void> sendMessage(String text) async {
    final user = _auth.currentUser; //Checks if the user is authenticated.
    if (user == null) throw Exception('Not authenticated'); //null check

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
      'mentionedUserIds': mentionedUserIds,
    });
  }

  //Extracts usernames mentioned in the message text using @
  Future<List<String>> _getMentionedUserIds(String text) async {
    final mentionRegex = RegExp(r'@(\w+)');
    //Queries the users collection to find the user ID for each mentioned username.
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

  //Deletes a message from the Firestore messages collection
  @override
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}