//todo add Animation
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/notifications/notification_page.dart';
import '../../../../responsive/constrained_scaffold.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../post/presentation/components/textpost_tile.dart';
import '../../../post/presentation/cubits/post_cubit.dart';
import '../../../post/presentation/cubits/post_state.dart';
import '../../../post/presentation/pages/upload_post_page.dart';
import '../../../privateMessaging/presentation/pages/messaging_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../post/presentation/components/post_tile.dart';
import 'package:oncesocial/features/search/presentation/pages/search_page.dart';
import '../../../publicChat/presentation/pages/chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Read your PostCubit from the context
  late final PostCubit postCubit = context.read<PostCubit>();
  final PageController _pageController = PageController();
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

  // Update _currentIndex and animate to the new page
  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.slowMiddle,
    );
  }

  // Returns a list of pages.
  //
  //The first page (home page) is now using a CustomScrollView with a SliverAppBar.
  List<Widget> _pages() {
    return [
      BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsLoading || state is PostUploading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsLoaded) {
            final allPosts = state.posts;
            return CustomScrollView(
              slivers: [
                // The SliverAppBar will hide on scroll down and reappear on scroll up.
                SliverAppBar(
                  title: const Text('mholo'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  floating: true,
                  snap: true,
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      ),
                      icon: Icon(
                        Icons.notifications,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPage(),
                        ),
                      ),
                      icon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
                // If there are no posts, fill the remaining space.
                if (allPosts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No Posts available')),
                  )
                else
                // Build a list of posts using SliverList.
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final post = allPosts[index];
                        if (post.imageUrl.isEmpty) {
                          return TextPostTile(
                            post: post,
                            onDeletePressed: () => deletePost(post.id),
                          );
                        } else {
                          return PostTile(
                            post: post,
                            onDeletePressed: () => deletePost(post.id),
                          );
                        }
                      },
                      childCount: allPosts.length,
                    ),
                  ),
              ],
            );
          } else if (state is PostsError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        },
      ),
      const ChatPage(),
      const UploadPostPage(),
      const MessagingPage(),
      ProfilePage(uid: context.read<AuthCubit>().currentUser!.uid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final inversePrimaryColor = Theme.of(context).colorScheme.inversePrimary;
    return ConstrainedScaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: inversePrimaryColor,
        unselectedItemColor: inversePrimaryColor.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.cyan,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Post',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'DM',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}
