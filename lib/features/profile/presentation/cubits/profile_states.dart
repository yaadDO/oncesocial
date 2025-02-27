import 'package:oncesocial/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState{}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;
  final Map<String, ProfileUser> followingProfiles;
  ProfileLoaded(this.profileUser, this.followingProfiles);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}