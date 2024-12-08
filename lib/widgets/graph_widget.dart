import 'package:flutter/material.dart';
import '/logic/graph.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart'
    as fdg;

class GraphWidget extends StatefulWidget {
  const GraphWidget({
    super.key,
    required this.path,
    required this.graph,
    this.iteration,
    required this.setFocused,
  });
  final String path;
  final Graph graph;
  final int? iteration;
  final Function setFocused;

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  fdg.ForceDirectedGraphController controller =
      fdg.ForceDirectedGraphController(
    minScale: 0.01,
    maxScale: 10,
  );

  void populateGraph() {
    for (Node node in widget.graph.nodes) {
      controller.addNode(node);
    }
    for (MyEdge edge in widget.graph.edges) {
      controller.addEdgeByData(
        widget.graph.nodes.firstWhere((e) => e.alias == edge.source),
        widget.graph.nodes.firstWhere((e) => e.alias == edge.target),
      );
    }
    setState(() {});
  }

  bool nodeATargetB(Node a, Node b) {
    for (MyEdge edge in widget.graph.edges) {
      if (edge.source == a.alias && edge.target == b.alias) {
        return true;
      }
    }
    return false;
  }

  int getNumber(int iter, Node node) {
    int index = widget.graph.sim.iterOrder.indexOf(node.alias);
    if (index == -1) {
      print("Could not find node in sim");
      print(widget.graph.sim.iterOrder.join("|"));
      print(node.alias);
      return 0;
    }
    return widget.graph.sim.iter[iter][index];
  }

  @override
  void didUpdateWidget(covariant GraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph != widget.graph) {
      controller.graph.edges.clear();
      controller.graph.nodes.clear();
      // controller.dispose();
      // controller.needUpdate();
      controller = fdg.ForceDirectedGraphController(
        minScale: 0.01,
        maxScale: 10,
      );
      populateGraph();
      controller.needUpdate();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    populateGraph();

    // dir = File(widget.path);

    // sub = dir!.watch().listen((event) {
    // if (event.type != FileSystemEvent.modify) {
    // Navigator.pop(context);
    // return;
    // }

    // update = Future.delayed(const Duration(milliseconds: 500)).then(
    // (_) => setState(
    // () {
    // controller.graph.edges.clear();
    // controller.graph.nodes.clear();
    // controller.dispose();
    // controller.needUpdate();
    // controller = fdg.ForceDirectedGraphController(
    // minScale: 0.01,
    // maxScale: 10,
    // );
    // populateGraph();
    // controller.needUpdate();
    // },
    // ),
    // );
    // return;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: fdg.ForceDirectedGraphWidget(
        edgeAlwaysUp: false,
        controller: controller,
        nodesBuilder: (context, data) {
          return GestureDetector(
            onTap: () {
              widget.setFocused(data);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              width: 55,
              height: 45,
              alignment: Alignment.center,
              child: widget.iteration != null
                  ? Text(
                      "${data.name.replaceAll("_", " ")}\n"
                      " ${getNumber(widget.iteration!, data as Node)}",
                      style: const TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      '${data.name.replaceAll("_", " ")}',
                      style: const TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
            ),
          );
        },
        edgesBuilder: (context, a, b, distance) {
          return GestureDetector(
            onTap: () {
              widget.setFocused(widget.graph.edges.firstWhere(
                (e) =>
                    e.source == (a as Node).alias &&
                    e.target == (b as Node).alias,
              ));
            },
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 1,
              ),
              width: distance - 50,
              height: 50,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Positioned(
                    left: 15,
                    right: 0,
                    top: 24,
                    child: Container(
                      height: 2,
                      color: Colors.black,
                    ),
                  ),
                  const Positioned(
                    left: -10,
                    // right: 0,
                    top: 2,
                    child: Icon(
                      Icons.arrow_left,
                      color: Colors.black,
                      size: 45,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
