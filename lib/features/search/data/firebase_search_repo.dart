//Defines a class FirebaseSearchRepo that implements the SearchRepo interface.
//The primary function of this repository is to search for users by name in a Firestore database.
// \uf8ff is a special character used in Firestore queries to ensure the range includes all possible characters after the query string
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oncesocial/features/profile/domain/entities/profile_user.dart';
import 'package:oncesocial/features/search/domain/search_repo.dart';

class FirebaseSearchRepo implements SearchRepo {
  @override
  //A Future that resolves to a list of ProfileUser objects. The result can also contain null values, indicated by ProfileUser?.
  Future<List<ProfileUser?>> searchUsers(String query) async {
    try{
      //Section performs the actual query in Firestore
      final result = await FirebaseFirestore.instance
          .collection('users') //Accesses the users collection in the Firestore database
          .where('name', isGreaterThanOrEqualTo: query) //Retrieves documents where the name field starts with or comes alphabetically after query.
          .where('name', isLessThanOrEqualTo: '$query\uf8ff') //Limits the query to names that start with query.
          .get(); //Executes the query and retrieves the results as a QuerySnapshot

      return result.docs
      .map((doc) => ProfileUser.fromJson(doc.data())) //Converts each document's data into a ProfileUser object by calling ProfileUser.fromJson().
      .toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }
}

//doc.data() returns a Map<String, dynamic> representing the document data, which is passed to the fromJson method of the ProfileUser class.
//result = = await FirebaseFirestore.instance
//Purpose: This code transforms Firestore documents into a list of ProfileUser objects.
// Result: You get a list of user profiles, ready to be displayed or further processed in the app.