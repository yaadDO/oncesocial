import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/auth/presentation/components/my_text_field.dart';
import 'package:oncesocial/features/auth/presentation/cubits/auth_cubit.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../cubits/post_cubit.dart';
import '../../../profile/domain/entities/profile_user.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';
import '../cubits/post_state.dart';
import 'comment_tile.dart';
import 'delete_dialog.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  //An instance of AppUser, representing the currently authenticated user.
  AppUser? currentUser;

  //An instance of AppUser, representing the currently authenticated user.
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  //Determine if the current user is the one who created the post.
  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  //Fetch the profile of the user who created the post
  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    //Checks if the post is already liked by the current user. If liked, it removes the current user's UID from the likes list; otherwise, it adds it.
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  final commentTextController = TextEditingController();

  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: MyTextField(
          controller: commentTextController,
          hintText: 'Comment...',
          obscureText: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              addComment();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  //Creates a new comment and adds it to the current post using the postCubit.
  //! force dart to treat it as non-nullable
  void addComment() {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userName: currentUser!.name,
      userId: currentUser!.uid,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    //Check ensures that an empty comment is not added.
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  //disposes to free up resources
  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  //Dialog box with options to delete the post
  void showOptions() => showDeleteDialog(
    context: context,
    title: 'Delete Post',
    onDelete: () => widget.onDeletePressed?.call(),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          //Displays Profile Picture on Post
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  uid: widget.post.userId,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                    imageUrl: postUser!.profileImageUrl,
                    //If no pfp is Detected
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.person),
                    imageBuilder: (context, imageProvider) => Container(
                      //Adjust the size
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        //Ensures pfp becomes out as a circle
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      : const Icon(Icons.person),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  //Checks if post isOwnPost
                  if (isOwnPost)
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          //Display Posted image
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 438),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      // like button logic
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                          widget.post.likes.contains(currentUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.post.likes.contains(currentUser!.uid)
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      //Amount of likes
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                //Amount of comments
                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                //Timestamp
                Text(
                  _formatTimestamp(widget.post.timestamp),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              children: [
                Text(
                  widget.post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(widget.post.text),
              ],
            ),
          ),

          //The BlocBuilder is used to rebuild the widget when the PostCubit's state changes
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostsLoaded) {
                final post = state.posts
                    .firstWhere((post) => (post.id == widget.post.id));
                if (post.comments.isNotEmpty) {
                  int showCommentCount = post.comments.length;
                  return ListView.builder(
                    itemCount: showCommentCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];

                      return CommentTile(comment: comment);
                    },
                  );
                }
              }
              if (state is PostsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is PostsError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }

//This method formats the timestamp of the post into a readable string
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
