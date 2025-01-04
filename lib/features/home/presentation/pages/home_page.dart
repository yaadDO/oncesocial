import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../post/presentation/cubits/post_cubit.dart';
import '../../../post/presentation/cubits/post_state.dart';
import '../../../post/presentation/pages/upload_post_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../post/presentation/components/post_tile.dart';
import 'package:oncesocial/features/search/presentation/pages/search_page.dart';
import 'package:oncesocial/features/settings/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubit>();
  int _currentIndex = 0;

  @override
  void initState() {
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

  // Updates _currentIndex when a navigation item is tapped and calls setState() to rebuild the widget with the new page.
  void _onNavItemTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
  }

  List<Widget> _pages() {
    return [
      BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          //Shows a loading spinner.
          if (state is PostsLoading || state is PostUploading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsLoaded) {
            final allPosts = state.posts;
            return allPosts.isEmpty
            //check if no posts availble
                ? const Center(child: Text('No Posts available'))
            //if posts are availble
                : ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];
                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              },
            );
          } else if (state is PostsError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        },
      ),



      // Search Page
      const SearchPage(),

      const UploadPostPage(),

      // Profile Page
      ProfilePage(uid: context.read<AuthCubit>().currentUser!.uid),

      // Settings Page
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages()[_currentIndex], // Display page based on index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.cyan,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Post',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}
