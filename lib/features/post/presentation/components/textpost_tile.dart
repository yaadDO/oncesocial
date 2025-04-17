// tetextpost_tile.dart
// textpost_tile.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/auth/presentation/components/my_text_field.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../profile/domain/entities/profile_user.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import '../cubits/post_cubit.dart';
import '../cubits/post_state.dart';
import 'comment_tile.dart';
import 'delete_dialog.dart';

class TextPostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const TextPostTile({
    super.key,
    required this.post,
    this.onDeletePressed,
  });

  @override
  State<TextPostTile> createState() => _TextPostTileState();
}

class _TextPostTileState extends State<TextPostTile> {
  bool isOwnPost = false;
  ProfileUser? postUser;
  late final ProfileCubit profileCubit;
  late final AppUser currentUser; // current user instance

  // Controller for adding comments.
  final commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser!;
    isOwnPost = widget.post.userId == currentUser.uid;
    profileCubit = context.read<ProfileCubit>();
    fetchPostUser();
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void showOptions() => showDeleteDialog(
    context: context,
    title: 'Delete Post',
    onDelete: () => widget.onDeletePressed?.call(),
  );

  // Opens a dialog to add a new comment.
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
            onPressed: () {
              Navigator.of(context).pop();
              commentTextController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              addComment();
              Navigator.of(context).pop();
              commentTextController.clear();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Creates a new comment and adds it using the PostCubit.
  void addComment() {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userName: currentUser.name,
      userId: currentUser.uid,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    if (commentTextController.text.isNotEmpty) {
      context.read<PostCubit>().addComment(widget.post.id, newComment);
    }
  }

  // This method implements the toggle like functionality.
  void toggleLikePost() {
    // Check if the current user has already liked the post.
    final isLiked = widget.post.likes.contains(currentUser.uid);

    // Optimistically update the UI
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser.uid);
      } else {
        widget.post.likes.add(currentUser.uid);
      }
    });

    // Call the PostCubit to update the backend
    context
        .read<PostCubit>()
        .toggleLikePost(widget.post.id, currentUser.uid)
        .catchError((error) {
      // If there is an error, revert the optimistic UI update.
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser.uid);
        } else {
          widget.post.likes.remove(currentUser.uid);
        }
      });
    });
  }

  // Format timestamp helper.
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile image, user name, and delete option.
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(uid: widget.post.userId),
                  ),
                ),
                child: postUser?.profileImageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: postUser!.profileImageUrl,
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.person),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                    : CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.post.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
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
          const SizedBox(height: 10),
          // The text content of the post.
          Text(
            widget.post.text,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          // Row for like, comment, and timestamp.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Like button implementation.
                GestureDetector(
                  onTap: toggleLikePost,
                  child: Icon(
                    widget.post.likes.contains(currentUser.uid)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.post.likes.contains(currentUser.uid)
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.post.likes.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                // Display the formatted timestamp.
                Text(
                  _formatTimestamp(widget.post.timestamp),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Display the list of comments.
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostsLoaded) {
                // Find the updated post.
                final post = state.posts.firstWhere(
                      (p) => p.id == widget.post.id,
                  orElse: () => widget.post,
                );
                if (post.comments.isNotEmpty) {
                  return ListView.builder(
                    itemCount: post.comments.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      return CommentTile(comment: comment);
                    },
                  );
                }
              } else if (state is PostsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PostsError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
