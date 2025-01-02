import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_cubit.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(


          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(followers, 'No followers', context),
            _buildUserList(following, 'No following', context),
          ],
        ),
      ),
    );
  }
  Widget _buildUserList(List<String> uids, String emptyMassage,  BuildContext context) {
    return uids.isEmpty
        ? Center(child: Text(emptyMassage))
        : ListView.builder(
        itemCount: uids.length,
        itemBuilder: (context, index) {
          final uid = uids[index];

          return FutureBuilder(
              future: context.read<ProfileCubit>().getUserProfile(uid),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  final user = snapshot.data!;
                  return ListTile(title: Text(user.name));
                }
                else if (snapshot.connectionState ==
                ConnectionState.waiting) {
                  return ListTile(title: Text('Loading..'));
                }
                else {
                  return ListTile(title: Text('User not found..'));
                }
              }
          );
        }
    );
  }
}
