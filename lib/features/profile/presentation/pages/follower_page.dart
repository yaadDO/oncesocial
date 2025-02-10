//FollowerPage that displays two tabs: one for the user's followers and another for the user's following list
//todo implement lazy loading

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_cubit.dart';

import '../../../../responsive/constrained_scaffold.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage({
    super.key,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    //Displays two tabs at the bottom of the AppBar
    return DefaultTabController(
      length: 2,
      child: ConstrainedScaffold(
        appBar: AppBar(
          bottom: TabBar(
            //Hides the divider between the tabs.
            dividerColor: Colors.transparent,
            //Customize the colors for selected and unselected tabs using the app's color scheme.
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,

            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),

        body:
        //Displays the content for the currently selected tab
        TabBarView(
          children: [
            _buildUserList(followers, 'No followers', context),
            _buildUserList(following, 'No following', context),
          ],
        ),
      ),
    );
  }
  Widget _buildUserList(List<String> uids, String emptyMessage, BuildContext context) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
      itemCount: uids.length,
      itemBuilder: (context, index) {
        final uid = uids[index];
        return FutureBuilder(
          future: context.read<ProfileCubit>().getUserProfile(uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final user = snapshot.data!;
              return ListTile(
                // Add profile image
                leading: CircleAvatar(
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                  child: user.profileImageUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user.name),
                // Add tap navigation
                onTap: () => _navigateToProfile(context, user.uid),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Loading...'),
              );
            } else {
              return const ListTile(title: Text('User not found'));
            }
          },
        );
      },
    );
  }

// Navigation handler
  void _navigateToProfile(BuildContext context, String uid) {
    Navigator.pushNamed(
      context,
      '/profile', // Replace with your actual profile route name
      arguments: uid,
    );
  }
}
