//This class is part of a Flutter Bloc architecture used to manage user authentication state in a Flutter application
//It extends the Cubit class, which emits different AuthState instances based on the authentication process's progress or outcome.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/auth/domain/entities/app_user.dart';
import '../../domain/repository/auth_repo.dart';
import 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  //initializes the AuthCubit with the initial state AuthInitial, indicating that no authentication process has started yet.
  AuthCubit({required this.authRepo}) : super(AuthInitial());

  //check if user is already authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  //Get current user
  //Private
  AppUser? get currentUser => _currentUser;

  //login
  Future<void> login(String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //register
  Future<void> register(String name, String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      await authRepo.signInWithGoogle();
      // After signing in with Google, fetch the current user
      final AppUser? user = await authRepo.getCurrentUser();

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

//logout
  Future<void> logout() async {
    authRepo.logout();
    emit(Unauthenticated());
  }
}
