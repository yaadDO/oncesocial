//auth repository - outlines the posible auth operations for this app
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oncesocial/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailPassword(String email, String password);
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();

  // New method for Google sign‑in
  Future<UserCredential?> signInWithGoogle();
}
