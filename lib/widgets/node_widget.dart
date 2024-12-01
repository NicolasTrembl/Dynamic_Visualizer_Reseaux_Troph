import 'package:flutter/material.dart';

import '/logic/graph.dart';

class NodeWidget extends StatefulWidget {
  const NodeWidget({
    super.key,
    required this.node,
    required this.forceUpdate,
    required this.graph,
  });

  final Node node;
  final void Function() forceUpdate;
  final Graph graph;

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.node.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              widget.node.alias,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
