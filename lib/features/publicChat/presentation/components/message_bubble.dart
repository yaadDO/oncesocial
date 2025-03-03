import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/profile/presentation/pages/profile_page.dart';
import '../../domain/entities/message.dart';
import '../cubits/chat_cubit.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe
            ? () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Message'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<ChatCubit>().deleteMessage(message.id);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          );
        }
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.tertiary
                : Colors.blueGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(uid: message.senderId),
                    ),
                  );
                },
                child: Text(
                  message.senderName.isEmpty ? 'Anonymous' : message.senderName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _buildMessageText(context),
              if (message.timestamp == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sending...',
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageText(BuildContext context) {
    final defaultColor = Theme.of(context).colorScheme.inversePrimary;
    return RichText(
      text: _parseMentions(message.text, defaultColor),
    );
  }

  TextSpan _parseMentions(String text, Color defaultColor) {
    final mentionRegex = RegExp(r'@(\w+)');
    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in mentionRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: defaultColor),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: defaultColor),
      ));
    }

    return TextSpan(children: spans);
  }
}