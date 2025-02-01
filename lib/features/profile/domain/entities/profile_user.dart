//This class extends the AppUser class and represents a user's profile with additional information such as bio, profile image URL, followers, and following.
import 'package:oncesocial/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;

  //Constructor uses the super keyword to pass common fields (uid, email, and name) to the base AppUser class.
  ProfileUser({
    required this.followers,
    required this.following,
    required super.uid,
    required super.email,
    required super.name,
    required this.bio,
    required this.profileImageUrl,
  });

  //Creates a copy of the current ProfileUser instance with the ability to update selected fields.
  //If a parameter is not provided (null), it retains the value from the existing instance using the ?? operator
  ProfileUser copyWith({
    String? newBio,
    String? newProfileImageUrl,
    List<String>? newFollowers,
    List<String>? newFollowing,
  }) {
    return ProfileUser(
      uid: uid,
      email: email,
      name: name,
      bio: newBio ?? bio,
      profileImageUrl: newProfileImageUrl ?? profileImageUrl,
      followers: newFollowers ?? followers,
      following: newFollowing ?? following,
    );
  }

//Converts a ProfileUser instance into a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
    };
  }

  //A factory constructor that creates a ProfileUser instance from a JSON-like Map<String, dynamic>.
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'] ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
    );
  }
}
