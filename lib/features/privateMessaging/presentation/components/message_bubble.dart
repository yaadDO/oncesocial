import 'package:flutter/material.dart';
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
          child: Text(
            messagepriv.messagepriv,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary
            ),
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
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onLongPress!(); // Trigger the delete action
              },
              icon: const Icon(Icons.delete, color: Colors.red,)
            ),
          ],
        );
      },
    );
  }
}