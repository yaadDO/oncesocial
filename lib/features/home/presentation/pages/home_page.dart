import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../post/presentation/cubits/post_cubit.dart';
import '../../../post/presentation/cubits/post_state.dart';
import '../../../post/presentation/pages/upload_post_page.dart';
import '../../components/my_drawer.dart';
import '../../../post/presentation/components/post_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late final postCubit = context.read<PostCubit>();

  @override
  void initState(){
    super.initState();
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadPostPage(),
                )),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      drawer: MyDrawer(),

      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsLoading && state is PostUploading) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(
                child: Text('No Posts available'),
              );
            }

            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];

                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              },
            );
          }

           else if (state is PostsError) {
             return Center(child: Text(state.message));
          } else {
             return const SizedBox();
          }
        },
      ),
    );
  }
}
