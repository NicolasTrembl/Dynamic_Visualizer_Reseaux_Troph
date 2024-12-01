import 'package:flutter/material.dart';

class GetPathDialog extends StatefulWidget {
  const GetPathDialog({super.key});

  @override
  State<GetPathDialog> createState() => _GetPathDialogState();
}

class _GetPathDialogState extends State<GetPathDialog> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      title: const Text('Enter the path to the folder'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Path',
        ),
        onSubmitted: (String value) {
          Navigator.pop(context, value);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Center(
            child: Text(
              'OK',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
