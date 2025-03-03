import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for DateFormat
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final MessagePrivate messagepriv;
  final bool isMe;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.messagepriv,
    required this.isMe,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          if (onLongPress != null) {
            _showDeleteConfirmationDialog(context);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.secondary
                : Colors.blueGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                messagepriv.messagepriv,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              if (isMe) // Only show status indicators for our own messages
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(messagepriv.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        messagepriv.read ? Icons.done_all : Icons.done,
                        size: 12,
                        color: messagepriv.read
                            ? Colors.blue
                            : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.7),
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                onLongPress!();
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        );
      },
    );
  }
}