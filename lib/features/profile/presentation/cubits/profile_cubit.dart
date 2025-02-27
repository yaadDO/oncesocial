//Handles various user profile operations, including fetching profiles, updating profile information, and toggling follow status
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/profile/domain/repository/profile_repo.dart';
import '../../../storage/domain/storage_repo.dart';
import '../../domain/entities/profile_user.dart';
import 'profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  //his field represents the repository for profile-related operations, such as fetching or updating user profiles.
  final ProfileRepo profileRepo;
  //This field represents the repository for handling image uploads, with separate methods for web and mobile platforms.
  final StorageRepo storageRepo;

  ProfileCubit({
    required this.profileRepo,
    required this.storageRepo,
  }) : super(ProfileInitial());

  //Fetches a user profile by their uid
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        // Fetch all followed users' profiles in parallel
        final futures = user.following
            .map((id) => profileRepo.fetchUserProfile(id))
            .toList();
        final followedUsers = await Future.wait(futures);

        final followingProfiles = <String, ProfileUser>{};
        for (final followedUser in followedUsers) {
          if (followedUser != null) {
            followingProfiles[followedUser.uid] = followedUser;
          }
        }

        emit(ProfileLoaded(user, followingProfiles));
      } else {
        emit(ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  //This method fetches a user profile and directly returns a ProfileUser object or null if the user is not found
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  //Updates the user's profile information
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
}) async {
    emit(ProfileLoading());

    try{
      //fetch current profile
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError('Failed to fetch user for updating profile'));
        return;
      }

      String? imageDownloadUrl;

      if(imageWebBytes != null || imageMobilePath != null) {
        if(imageMobilePath != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
        }
        else if (imageWebBytes != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError('Failed to upload image'));
          return;
        }
      }

      //update new profile
      final updatedProfile =
          currentUser.copyWith(newBio: newBio ?? currentUser.bio,
          newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
          );

      //update in repo
      await profileRepo.updateProfile(updatedProfile);

      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError('Error updating profile: $e' ));
    }
  }

  //This method toggles the follow/unfollow status between the current user and a target user.
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId);
      // Refetch the current user's profile to update the following list
      await fetchUserProfile(currentUserId);
    } catch (e) {
      emit(ProfileError('Error toggling follow: $e'));
    }
  }
}

















