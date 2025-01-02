import '../../domain/entities/post.dart';

abstract class PostState {}

class PostsInitial extends PostState {}

class PostsLoading extends PostState {}

class PostUploading extends PostState {}

class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}

class PostsLoaded extends PostState {
  final List<Post> posts;

  PostsLoaded(this.posts);
}
