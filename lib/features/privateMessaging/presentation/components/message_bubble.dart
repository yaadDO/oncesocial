import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';


class MessageBubble extends StatelessWidget {
  final MessagePrivate messagepriv;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.messagepriv,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          messagepriv.messagepriv,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
