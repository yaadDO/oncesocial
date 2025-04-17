//todo add Animation
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/auth/domain/entities/app_user.dart';
import 'package:oncesocial/features/notifications/presentation/cubits/notification_cubit.dart';
import 'package:oncesocial/features/notifications/presentation/cubits/notification_state.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_states.dart';
import '../../../../web/constrained_scaffold.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_states.dart';
import '../../../notifications/presentation/pages/notification_page.dart';
import '../../../post/presentation/components/textpost_tile.dart';
import '../../../post/presentation/cubits/post_cubit.dart';
import '../../../post/presentation/cubits/post_state.dart';
import '../../../post/presentation/pages/upload_post_page.dart';
import '../../../privateMessaging/presentation/pages/messaging_page.dart';
import '../../../profile/domain/entities/profile_user.dart';
import '../../../profile/presentation/cubits/profile_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../post/presentation/components/post_tile.dart';
import 'package:oncesocial/features/search/presentation/pages/search_page.dart';
import '../../../publicChat/presentation/pages/chat_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PostCubit postCubit = context.read<PostCubit>();
  final PageController _pageController = PageController();
  late final profileCubit = context.read<ProfileCubit>();
  int _currentIndex = 0;
  AppUser? currentUser;
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
    getCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCubit = context.read<AuthCubit>();
      if (authCubit.state is Authenticated) {
        final currentUserId = authCubit.currentUser!.uid;
        profileCubit.fetchUserProfile(currentUserId);
      }
    });
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

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

  List<Widget> _pages() {
    return [
      BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context);
          if (state is PostsLoading || state is PostUploading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsLoaded) {
            final allPosts = state.posts;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: const Text('mholo'),
                  backgroundColor: Theme.of(context).colorScheme.surface,
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
                      icon: BlocBuilder<NotificationCubit, NotificationState>(
                        builder: (context, state) {
                          final unreadCount =
                              context.select<NotificationCubit, int>(
                            (cubit) => (cubit.state is NotificationsLoaded)
                                ? (cubit.state as NotificationsLoaded)
                                    .notifications
                                    .where((n) => !n.read)
                                    .length
                                : 0,
                          );
                          return badges.Badge(
                            position:
                                badges.BadgePosition.topEnd(top: -8, end: -8),
                            badgeContent: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                            showBadge: unreadCount > 0,
                            child: Icon(
                              Icons.notifications,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          );
                        },
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
                if (allPosts.isEmpty)
                  SliverFillRemaining(
                    child: Center(child: Text(l10n.noPosts)),
                  )
                else
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
    return ConstrainedScaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages(),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        color: Colors.cyan,
        buttonBackgroundColor: Colors.cyan,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.linear,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _onNavItemTapped,
        items: [
          const Icon(Icons.home, size: 30, color: Colors.white),
          const Icon(Icons.chat, size: 30, color: Colors.white),
          const Icon(Icons.add, size: 30, color: Colors.white),
          const Icon(Icons.send, size: 30, color: Colors.white),
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded && state.profileUser.profileImageUrl.isNotEmpty) {
                return CachedNetworkImage(
                  imageUrl: state.profileUser.profileImageUrl,
                  errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white),
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
                );
              }
              return const Icon(Icons.person, color: Colors.white);
            },
          ),
        ],
      ),
    );
  }
}
