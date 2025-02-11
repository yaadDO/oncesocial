import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/privateMessaging/domain/entities/message.dart';


import '../../../auth/presentation/cubits/auth_cubit.dart';


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

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthCubit>().currentUser!;
    _chatRoomId = _generateChatRoomId(currentUser.uid);
    _msgCubit = context.read<MsgCubit>();
    _msgCubit.loadMessages(_chatRoomId);
  }

  String _generateChatRoomId(String currentUserId) {
    final ids = [currentUserId, widget.receiverId]..sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MsgCubit, MsgState>(
              builder: (context, state) {
                if (state is MsgLoaded) {
                  if (state.messagesPrivate.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: state.messagesPrivate.length,
                    itemBuilder: (context, index) {
                      final messagepriv = state.messagesPrivate[index];
                      final currentUser = context.read<AuthCubit>().currentUser!;
                      return MessageBubble(
                        messagepriv: messagepriv,
                        isMe: messagepriv.senderId == currentUser.uid,
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