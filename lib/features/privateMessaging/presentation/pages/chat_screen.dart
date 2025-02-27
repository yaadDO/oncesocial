import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/privateMessaging/domain/entities/message.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../profile/data/firebase_profile_repo.dart';
import '../../../profile/domain/entities/profile_user.dart';
import '../components/message_bubble.dart';
import '../cubits/msg_cubit.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final MsgCubit _msgCubit;
  final TextEditingController _textController = TextEditingController();
  late String _chatRoomId;
  late ScrollController _scrollController;
  late Future<ProfileUser?> _receiverProfileFuture;

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthCubit>().currentUser!;
    _chatRoomId = _generateChatRoomId(currentUser.uid);
    _msgCubit = context.read<MsgCubit>();
    _msgCubit.loadMessages(_chatRoomId);
    _scrollController = ScrollController();
    _receiverProfileFuture = FirebaseProfileRepo().fetchUserProfile(widget.receiverId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _generateChatRoomId(String currentUserId) {
    final ids = [currentUserId, widget.receiverId]..sort();
    return ids.join('_');
  }

  // Updated _scrollToBottom method for non-reversed ListView
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<ProfileUser?>(
          future: _receiverProfileFuture,
          builder: (context, snapshot) {
            // Show name immediately while loading profile
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(widget.receiverName);
            }
            // Show profile picture and name when loaded
            if (snapshot.hasData && snapshot.data != null) {
              final user = snapshot.data!;
              return Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.profileImageUrl),
                    radius: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(user.name, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
                ],
              );
            }
            // Fallback to just name if no profile data
            return Text(widget.receiverName);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MsgCubit, MsgState>(
              builder: (context, state) {
                if (state is MsgLoaded) {
                  if (state.messagesPrivate.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }

                  // Check if the last message is from the current user
                  final currentUser = context.read<AuthCubit>().currentUser!;
                  final lastMessage = state.messagesPrivate.last;
                  if (lastMessage.senderId == currentUser.uid) {
                    _scrollToBottom();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    // Remove reverse: true so that messages are shown in order
                    itemCount: state.messagesPrivate.length,
                    itemBuilder: (context, index) {
                      final messagepriv = state.messagesPrivate[index];
                      return MessageBubble(
                        messagepriv: messagepriv,
                        isMe: messagepriv.senderId == currentUser.uid,
                        onLongPress: messagepriv.senderId == currentUser.uid
                            ? () => _msgCubit.deleteMessage(messagepriv.id)
                            : null,
                      );
                    },
                  );
                } else if (state is MsgError) {
                  return Center(child: Text(state.error));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final currentUser = context.read<AuthCubit>().currentUser!;
              final message = MessagePrivate(
                senderId: currentUser.uid,
                receiverId: widget.receiverId,
                messagepriv: _textController.text,
                timestamp: DateTime.now(),
                chatRoomId: _chatRoomId,
                id: '',
              );
              _msgCubit.sendMessage(message);
              _textController.clear();
            },
          ),
        ],
      ),
    );
  }
}
