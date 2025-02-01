//Manages posts and comments in application using Firebase Firestore as the backend
//Fuction Methods
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oncesocial/features/post/domain/entities/comment.dart';
import 'package:oncesocial/features/post/domain/entities/post.dart';
import 'package:oncesocial/features/post/domain/repos/post_repo.dart';

//postsSnapshot is the result of a Firestore query, and docs is a list of documents returned by that query.
class FirebasePostRepo implements PostRepo{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      //Adds a new document with the post's ID and converts the Post object to JSON using toJson().
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      //Retrieves all documents from the 'posts' collection, ordered by the timestamp field.
      final postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();

      //Converts each Firestore document to a Post object using Post.fromJson
      final List<Post> allPosts = postsSnapshot.docs
      .map((doc) => Post.fromJson(doc.data() as Map<String,dynamic>))
      .toList();

      return allPosts;
    }catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      final postsSnapshot =
      //Queries Firestore for posts where the 'userId' field matches the given userId.
          await postsCollection.where('userId', isEqualTo: userId).get();

      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String,dynamic>))
          .toList();
      return userPosts;
    } catch (e) {
      throw Exception('Error fetching posts by user: $e');
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
   try{
     final postDoc = await postsCollection.doc(postId).get();

     if(postDoc.exists) {
       final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

       final hasLiked = post.likes.contains(userId);

       if(hasLiked){
         post.likes.remove(userId);
       } else {
         post.likes.add(userId);
       }

       await postsCollection.doc(postId).update({
         'likes': post.likes,
       });
     } else {
       throw Exception('Post not found');
     }
   }
   catch (e) {
     throw Exception('Error toggling like: $e');
   }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if(postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        post.comments.add(comment);
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if(postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        post.comments.removeWhere((comment) => comment.id == commentId);

        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error deleting comment: $e');
    }
  }
}