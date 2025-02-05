//todo add Animation
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../responsive/constrained_scaffold.dart';
import '../../../../themes/themes_cubit.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../post/presentation/cubits/post_cubit.dart';
import '../../../post/presentation/cubits/post_state.dart';
import '../../../post/presentation/pages/upload_post_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../post/presentation/components/post_tile.dart';
import 'package:oncesocial/features/search/presentation/pages/search_page.dart';
import 'package:oncesocial/features/settings/pages/settings_page.dart';

import '../../../publicChat/presentation/pages/chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PostCubit postCubit = context.read<PostCubit>();
  final PageController _pageController = PageController(); // Controller for PageView
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of PageController
    super.dispose();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  // Updates _currentIndex and animates to the new page
  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.slowMiddle,
    );
  }

  List<Widget> _pages() {
    return [
      BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsLoading || state is PostUploading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsLoaded) {
            final allPosts = state.posts;
            return allPosts.isEmpty
                ? const Center(child: Text('No Posts available'))
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
      const ChatPage(),
      const SearchPage(),
      const UploadPostPage(),
      ProfilePage(uid: context.read<AuthCubit>().currentUser!.uid),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final inversePrimaryColor = Theme.of(context).colorScheme.inversePrimary;
    return ConstrainedScaffold(
      body: PageView(
        controller: _pageController, // Connect PageController
        physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures
        children: _pages(), // Display pages
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: inversePrimaryColor, // Use inversePrimary for selected items
        unselectedItemColor: inversePrimaryColor.withOpacity(0.6), // Slightly faded for unselected items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.cyan,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            backgroundColor: Colors.blue,
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
