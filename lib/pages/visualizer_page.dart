import 'package:flutter/material.dart';

import '/widgets/graph_widget.dart';
import '/widgets/get_path_widget.dart';

class VisualizerPage extends StatefulWidget {
  const VisualizerPage({super.key});

  @override
  State<VisualizerPage> createState() => _VisualizerPageState();
}

class _VisualizerPageState extends State<VisualizerPage> {
  String path = '';
  int view = 0;
  bool showValue = false;

  void getPath() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final String? newPath = await showDialog<String>(
      context: context,
      builder: (context) => const GetPathDialog(),
      barrierDismissible: false,
    );
    if (newPath != null) {
      setState(() {
        path = newPath;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: path.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GraphWidget(
              paths: [
                "$path\\output.eco",
                "$path\\output.sim",
              ],
            ),
    );
  }
}
