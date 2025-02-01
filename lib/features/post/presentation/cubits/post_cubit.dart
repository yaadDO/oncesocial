//This class is a Cubit in app that uses the BLoC
// pattern to manage state. The PostCubit class is responsible for handling the creation, deletion, and retrieval of posts, as well as comments and likes.

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/post/presentation/cubits/post_state.dart';
import '../../../storage/domain/storage_repo.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repos/post_repo.dart';

class PostCubit extends Cubit<PostState> {
  //Responsible for interacting with the data layer
  final PostRepo postRepo;
  //Handles image uploads for posts
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  //create a new post
  Future<void> createPost(Post post,
  {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    //This method creates a new post. It can optionally handle image uploads for both:
    //Mobile uploads or Web uploads

    //mobile uploads
    try {
    if(imagePath != null) {
      emit(PostUploading());
      imageUrl =
      await storageRepo.uploadPostImageMobile(imagePath, post.id);
    }
    //web upload
    else if(imageBytes != null){
      emit(PostUploading());
      imageUrl =
      await storageRepo.uploadPostImageWeb(imageBytes, post.id);
    }

    //Creates a new post by calling createPost() on the PostRepo
    final newPost = post.copyWith(imageUrl: imageUrl);

    postRepo.createPost(newPost);

    fetchAllPosts();

  } catch (e) {
    emit(PostsError('Failed to crete post: $e'));
  }
}

Future<void> fetchAllPosts() async {
  try {
    emit(PostsLoading());
    final posts = await postRepo.fetchAllPosts();
    emit(PostsLoaded(posts));
  } catch (e) {
    emit(PostsError('Failed to fetch posts: $e'));
  }
}

   Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {}
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try{
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostsError('Failed to toggle likes: $e'));
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsError('Failed to add comments: $e'));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsError('Failed to delete comment: $e'));
    }
  }
}
