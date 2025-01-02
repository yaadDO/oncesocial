import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/profile/domain/repository/profile_repo.dart';
import '../../../storage/domain/storage_repo.dart';
import '../../domain/entities/profile_user.dart';
import 'profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({
    required this.profileRepo,
    required this.storageRepo,
  }) : super(ProfileInitial());

  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if(user != null) {
        emit(ProfileLoaded(user));
      } else{
        emit(ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

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

  Future <void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId);
    } catch (e) {
      emit(ProfileError('Error toggling follow: $e'));
    }
  }
}

















