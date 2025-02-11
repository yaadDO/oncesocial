import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showDeleteDialog({
  required BuildContext context,
  required String title,
  required VoidCallback onDelete,
  Color deleteColor = Colors.red,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        IconButton(
          onPressed: () {
            onDelete();
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.delete, color: deleteColor),
        ),
      ],
    ),
  );
}