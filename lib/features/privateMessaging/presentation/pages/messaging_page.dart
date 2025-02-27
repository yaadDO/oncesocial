import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_states.dart';
import '../../data/firebase_msg_repo.dart';
import '../cubits/msg_cubit.dart';
import 'chat_screen.dart';

// Updated MessagingPage
class MessagingPage extends StatelessWidget {
  const MessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return Scaffold(
            body: ListView.builder(
              itemCount: state.profileUser.following.length,
              itemBuilder: (context, index) {
                final userId = state.profileUser.following[index];
                final userProfile = state.followingProfiles[userId];

                if (userProfile == null) {
                  return const ListTile(title: Text('Loading...'));
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userProfile.profileImageUrl),
                  ),
                  title: Text(userProfile.name),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => MsgCubit(msgRepo: FirebaseMsgRepo()),
                        child: ChatScreen(
                          receiverId: userId,
                          receiverName: userProfile.name,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}