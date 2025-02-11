import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/profile/data/firebase_profile_repo.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_states.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../profile/domain/entities/profile_user.dart';
import '../../data/firebase_msg_repo.dart';
import '../cubits/msg_cubit.dart';
import 'chat_screen.dart';

class MessagingPage extends StatelessWidget {
  const MessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser!;
    final profileRepo = FirebaseProfileRepo();

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return Scaffold(
            /*appBar: AppBar(
              title: Text(
                'Chat Rooms',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary
                ),
              ),
            ),*/
            body: ListView.builder(
              itemCount: state.profileUser.following.length,
              itemBuilder: (context, index) {
                final userId = state.profileUser.following[index];
                return FutureBuilder<ProfileUser?>(
                  future: profileRepo.fetchUserProfile(userId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final user = snapshot.data!;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.profileImageUrl),
                        ),
                        title: Text(user.name),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) => MsgCubit(
                                msgRepo: FirebaseMsgRepo(),
                              ),
                              child: ChatScreen(
                                receiverId: userId,
                                receiverName: user.name,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const ListTile(title: Text('Loading...'));
                  },
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
