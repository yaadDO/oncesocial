
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/post/presentation/cubits/post_state.dart';
import 'package:oncesocial/features/profile/presentation/components/follow_button.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_states.dart';
import 'package:oncesocial/features/profile/presentation/pages/follower_page.dart';
import 'package:oncesocial/features/settings/pages/settings_page.dart';
import '../../../../responsive/constrained_scaffold.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../post/presentation/components/post_tile.dart';
import '../../../post/presentation/components/textpost_tile.dart';
import '../../../post/presentation/cubits/post_cubit.dart';
import '../components/bio_box.dart';
import '../components/profile_stats.dart';
import 'edit_profile_page.dart';
// Import the text post tile component.


class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Provides information about the currently authenticated user
  late final authCubit = context.read<AuthCubit>();
  // Manages fetching and updating user profile data
  late final profileCubit = context.read<ProfileCubit>();

  late AppUser? currentUser = authCubit.currentUser;

  int postCount = 0;

  @override
  void initState() {
    super.initState();
    // Fetch the profile data of the user identified by widget.uid when the page is loaded.
    profileCubit.fetchUserProfile(widget.uid);
  }

  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid);

    // Optionally, update the local state again if needed.
    setState(() {
      if (isFollowing) {
        profileUser.followers.add(currentUser!.uid);
      } else {
        profileUser.followers.remove(currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;

          return ConstrainedScaffold(
            appBar: AppBar(
              title: Text(
                user.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                if (isOwnPost)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    ),
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: user),
                    ),
                  ),
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
            body: ListView(
              children: [
                const SizedBox(height: 20),
                // Uses CachedNetworkImage to load the profile picture efficiently.
                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Tapping navigates to the FollowerPage to view detailed follower/following lists.
                ProfileStats(
                  postCount: postCount,
                  followerCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowerPage(
                        followers: user.followers,
                        following: user.following,
                      ),
                    ),
                  ),
                ),
                if (!isOwnPost)
                // FollowButton triggers follow/unfollow actions.
                  FollowButton(
                    onPressed: followButtonPressed,
                    isFollowing: user.followers.contains(currentUser!.uid),
                  ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    children: [
                      Text(
                        'Bio',
                        style: TextStyle(
                            color:
                            Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 1, 10, 1),
                  child: BioBox(text: user.bio),
                ),
                const SizedBox(height: 15),
                // Display posts related to the widget.uid or show a loading indicator.
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    if (state is PostsLoaded) {
                      final userPosts = state.posts
                          .where((post) => post.userId == widget.uid)
                          .toList();

                      postCount = userPosts.length;

                      return ListView.builder(
                        itemCount: postCount,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final post = userPosts[index];
                          // Check if the post is a text post (imageUrl empty) or image post.
                          if (post.imageUrl.isEmpty) {
                            return TextPostTile(
                              post: post,
                              onDeletePressed: () => context
                                  .read<PostCubit>()
                                  .deletePost(post.id),
                            );
                          } else {
                            return PostTile(
                              post: post,
                              onDeletePressed: () => context
                                  .read<PostCubit>()
                                  .deletePost(post.id),
                            );
                          }
                        },
                      );
                    } else if (state is PostsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(
                        child: Text('No Posts'),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(
            child: Text('No profile found'),
          );
        }
      },
    );
  }
}
