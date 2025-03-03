import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/publicChat/presentation/components/message_bubble.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../cubits/chat_cubit.dart';
import '../cubits/chat_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupFirebaseNotifications();
  }

  void _setupFirebaseNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final senderId = message.data['senderId'];
      final currentUserId = context.read<AuthCubit>().currentUser?.uid;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthCubit>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat Publicly',
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatError) {
                  return Center(child: Text(state.message));
                }
                if (state is! ChatLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = state.messages;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0.0);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return Dismissible(
                      key: Key(message.id),
                      direction: isMe
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      onDismissed: (_) => context.read<ChatCubit>().deleteMessage(message.id),
                      background: Container(color: Colors.red),
                      child: MessageBubble(
                        message: message,
                        isMe: isMe,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: (text) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatCubit>().sendMessage(text);
      _controller.clear();
    }
  }
}