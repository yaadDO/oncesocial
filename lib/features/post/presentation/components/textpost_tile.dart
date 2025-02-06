// tetextpost_tile.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/post.dart';
import '../cubits/post_cubit.dart';
import '../cubits/post_state.dart';
import 'comment_tile.dart';

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
  // Here you could add current user info similar to PostTile

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthCubit>().currentUser;
    isOwnPost = widget.post.userId == currentUser!.uid;
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeletePressed?.call();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Format timestamp (you may want to refactor this into a helper)
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and delete option
          Row(
            children: [
              // You can add a profile image if available:
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                // If you have a profile image URL, you could use CachedNetworkImage:
                child: Icon(Icons.person, color: Theme.of(context).colorScheme.inversePrimary),
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
          // The text content (like a tweet)
          Text(
            widget.post.text,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          // Timestamp
          Text(
            _formatTimestamp(widget.post.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
          ),
          // (Optional) You can add buttons for likes/comments if needed
          // For example, a Row with icons and counts
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              // Here you could display comment counts or similar details
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
