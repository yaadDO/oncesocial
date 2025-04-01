import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_states.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../data/firebase_msg_repo.dart';
import '../cubits/msg_cubit.dart';
import 'chat_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Updated MessagingPage
class MessagingPage extends StatelessWidget {
  const MessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentUserId = context.read<AuthCubit>().currentUser!.uid;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return Scaffold(
            body: ListView.builder(
              itemCount: state.profileUser.following.length,
              itemBuilder: (context, index) {
                final userId = state.profileUser.following[index];
                final userProfile = state.followingProfiles[userId];

                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(userProfile?.profileImageUrl ?? ''),
                      ),
                      StreamBuilder<int>(
                        stream: context.read<MsgCubit>().getUnreadCount(currentUserId, userId),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          if (count > 0) {
                            return Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  title: Text(userProfile?.name ?? l10n.loading),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => MsgCubit(msgRepo: FirebaseMsgRepo()),
                        child: ChatScreen(
                          receiverId: userId,
                          receiverName: userProfile?.name ?? '',
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