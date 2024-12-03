import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GetPathDialog extends StatefulWidget {
  const GetPathDialog({super.key});

  @override
  State<GetPathDialog> createState() => _GetPathDialogState();
}

enum ClipStatus { searching, notfound, valid, invalid }

class _GetPathDialogState extends State<GetPathDialog> {
  final TextEditingController controller = TextEditingController();

  ClipStatus status = ClipStatus.searching;

  bool isPathValid(String path) {
    if (path.isEmpty) return false;

    if (!path.contains("output")) return false;

    return true;
  }

  static Future<ClipboardData?> getData(String format) async {
    final Map<String, dynamic>? result =
        await SystemChannels.platform.invokeMethod(
      'Clipboard.getData',
      format,
    );
    if (result == null) {
      return null;
    }
    return ClipboardData(text: result['text'] as String);
  }

  void readFromClipboard() async {
    final ClipboardData? data = await getData('text/plain');
    if (data == null) {
      status = ClipStatus.notfound;
    } else if (isPathValid(data.text!)) {
      status = ClipStatus.valid;
      controller.text = data.text!;
    } else {
      status = ClipStatus.invalid;
    }
    setState(() {});
  }

  @override
  void initState() {
    readFromClipboard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text('Enter the path to the folder'),
      content: SizedBox(
        width: 300,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: controller,
              showCursor: false,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: const InputDecoration(
                hintText: 'Path',
              ),
              onSubmitted: (String value) {
                Navigator.pop(context, value);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (status == ClipStatus.searching)
                        ? "Searching in your clipboard..."
                        : (status == ClipStatus.notfound)
                            ? "No path found in your clipboard"
                            : (status == ClipStatus.valid)
                                ? "Path found in your clipboard"
                                : "Invalid path found in your clipboard",
                    style: TextStyle(
                      color: (status == ClipStatus.searching)
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : (status == ClipStatus.notfound)
                              ? Theme.of(context).colorScheme.error
                              : (status == ClipStatus.valid)
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                  Icon(
                    (status == ClipStatus.searching)
                        ? Icons.search
                        : (status == ClipStatus.notfound)
                            ? Icons.error
                            : (status == ClipStatus.valid)
                                ? Icons.check
                                : Icons.close,
                    color: (status == ClipStatus.searching)
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : (status == ClipStatus.notfound)
                            ? Theme.of(context).colorScheme.error
                            : (status == ClipStatus.valid)
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
          ],
        ),
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
