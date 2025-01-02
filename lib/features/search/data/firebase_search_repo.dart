import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oncesocial/features/profile/domain/entities/profile_user.dart';
import 'package:oncesocial/features/search/domain/search_repo.dart';

class FirebaseSearchRepo implements SearchRepo {
  @override
  Future<List<ProfileUser?>> searchUsers(String query) async {
    try{
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return result.docs
      .map((doc) => ProfileUser.fromJson(doc.data()))
      .toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }
}