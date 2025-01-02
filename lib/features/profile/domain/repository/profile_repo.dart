import 'package:oncesocial/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchUserProfile(String uid);
  Future<void> updateProfile(ProfileUser updatedProfile);
  Future<void> toggleFollow(String currentUis, String targetUid);
 }