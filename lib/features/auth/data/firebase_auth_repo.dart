import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oncesocial/features/auth/domain/entities/app_user.dart';
import 'package:oncesocial/features/auth/domain/repository/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await firebaseFirestore
      .collection('users')
      .doc(userCredential.user!.uid)
      .get();

      AppUser user = AppUser(
          uid: userCredential.user!.uid,
          email: email,
          name: userDoc['name'],
      );

     return user;
    }

    catch (e) {
      throw Exception('Login Failed: $e' );
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      await firebaseFirestore
       .collection('users')
       .doc(user.uid)
       .set(user.toJson());

      return user;
    }

    catch (e) {
      throw Exception('Login Failed: $e');
    }

  }


  @override
  Future<void> logout() async {
     await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
   final firebaseUser = firebaseAuth.currentUser;

   if(firebaseUser == null) {
     return null;
   }

   DocumentSnapshot userDoc =
       await firebaseFirestore.collection('users').doc(firebaseUser.uid).get();

   if (!userDoc.exists) {
     return null;
   }

   return AppUser(
       uid: firebaseUser.uid,
       email: firebaseUser.email!,
       name: userDoc['name'],
   );
  }
}