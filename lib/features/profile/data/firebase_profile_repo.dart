//Code interacts with Firebase Firestore to manage user profiles, including fetching profile data, updating profile information, and handling follow/unfollow actions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oncesocial/features/profile/domain/entities/profile_user.dart';

import '../domain/repository/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  //Fetches the user profile by retrieving a document from the users collection in Firestore using the user’s unique ID
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        if (userData != null) {
          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);

          return ProfileUser(
            uid: uid,
            email: userData['email'],
            name: userData['name'],
            bio: userData['bio'] ?? '',
            profileImageUrl: userData['profileImageUrl'].toString(),
            followers: followers,
            following: following,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //Updates the profile data for a user in the Firestore users collection by:
  // Locating the document using the user’s unique ID (uid).
  // Updating the bio and profileImageUrl fields with the values from updatedProfile.
  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update({
        'bio': updatedProfile.bio,
        'profileImageUrl': updatedProfile.profileImageUrl,
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  //Handles follow/unfollow functionality between two users:
  @override
  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      //Fetches the current user’s document (currentUserDoc) and the target user’s document (targetUserDoc) from Firestore.
      final currentUserDoc =
      await firebaseFirestore.collection('users').doc(currentUid).get();
      final targetUserDoc =
      await firebaseFirestore.collection('users').doc(targetUid).get();

      //Checks if both documents exist and have data.
      if (currentUserDoc.exists && targetUserDoc.exists) {
        //Extracts the current user's following list.
        final currentUserData = currentUserDoc.data();
        final targetUserData = targetUserDoc.data();

        if (currentUserData != null && targetUserData != null) {
          final List<String> currentFollowing =
          List<String>.from(currentUserData['following'] ?? []);

          //Removes the target user from the following list of the current user.
          if (currentFollowing.contains(targetUid)) {
            await firebaseFirestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayRemove([targetUid])
            });
            await firebaseFirestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayRemove([currentUid])
            });
          } else {
            await firebaseFirestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayUnion([targetUid])
            });
            await firebaseFirestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayUnion([currentUid])
            });
          }
        }
      }
    } catch (e) {}
  }
  @override
  Future<List<ProfileUser>> fetchUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    final users = <ProfileUser>[];
    // Process in chunks of 10 due to Firestore limitations
    for (var i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(
        i,
        i + 10 > uids.length ? uids.length : i + 10,
      );
      final querySnapshot = await firebaseFirestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        users.add(ProfileUser(
          uid: doc.id,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
          bio: data['bio'] ?? '',
          profileImageUrl: data['profileImageUrl'] ?? '',
          followers: List<String>.from(data['followers'] ?? []),
          following: List<String>.from(data['following'] ?? []),
        ));
      }
    }
    return users;
  }
}

