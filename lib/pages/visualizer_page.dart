import 'dart:async';
import 'dart:io';

import 'package:dynamic_visualizer/widgets/sim_widget.dart';
import 'package:flutter/material.dart';
import '/logic/save.dart';
import '/logic/graph.dart';
import '/widgets/graph_widget.dart';

class VisualizerPage extends StatefulWidget {
  const VisualizerPage({super.key, required this.path});

  final String path;

  @override
  State<VisualizerPage> createState() => _VisualizerPageState();
}

enum View {
  fullscreen,
  dense,
}

class _VisualizerPageState extends State<VisualizerPage> {
  View view = View.fullscreen;
  bool noSimData = true;
  bool showData = false;

  Graph? graph;
  File? dir;
  File? fileEco;
  File? fileSim;

  late StreamSubscription sub;

  DateTime? lastUpdate;

  @override
  void initState() {
    super.initState();
    dir = File(widget.path);
    fileEco = File("${widget.path}\\output.eco");
    fileSim = File("${widget.path}\\output.sim");

    fileEco!.readAsString().then((String eco) {
      fileSim!.readAsString().then((String sim) {
        if (sim.contains(":-")) {
          noSimData = false;
        }
        setState(() {
          graph = Graph.fromFile(eco, sim);
        });
      });
    });

    sub = dir!.watch().listen((event) {
      if (event.type != FileSystemEvent.modify) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        return;
      }

      String sim = fileSim!.readAsStringSync();

      if (sim.contains(":-")) {
        noSimData = false;
      }

      setState(() {
        graph = Graph.fromFile(fileEco!.readAsStringSync(), sim);
      });
      return;
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: graph == null
          ? const Center(child: CircularProgressIndicator())
          : (view == View.fullscreen)
              ? FullscreenPage(
                  path: widget.path,
                  graph: graph!,
                  showData: showData,
                )
              : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(graph != null ? graph!.name : 'Visualizer'),
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.text_snippet_outlined),
          // ),
          // IconButton(
          //   onPressed: () {
          //     setState(() {});
          //   },
          //   icon: const Icon(Icons.grid_view_outlined),
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton(
              child: const Icon(Icons.download),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text("Export as .dot"),
                      subtitle: const Text(
                        "Export the nodes and edges as a .dot / .gv file",
                      ),
                      onTap: () {
                        Export().exportToDot(graph);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text("Export as .graphml"),
                      subtitle: const Text(
                        "Export the nodes and edges as a .grapml file",
                      ),
                      onTap: () {
                        Export().exportToGrahpml(graph);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text("Export as .gexf"),
                      subtitle: const Text(
                        "Export the nodes and edges as a .gexf file (the gephi format)",
                      ),
                      onTap: () {
                        Export().exportToGexf(graph);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text("Export as .json"),
                      subtitle: const Text(
                        "Export the graph and the simulation as a .json file",
                      ),
                      onTap: () {
                        Export().exportToJson(graph);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text("Export as .csv"),
                      subtitle: const Text(
                        "Export the simulation as a .csv file",
                      ),
                      onTap: () {
                        Export().exportToCsv(graph);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      title: const Text("Export as .xlsx"),
                      subtitle: const Text(
                        "Export the simulation as a .xlsx file (the excel format)",
                      ),
                      onTap: () {
                        Export().exportToXlsx(graph);
                      },
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FullscreenPage extends StatefulWidget {
  const FullscreenPage({
    super.key,
    required this.path,
    required this.graph,
    required this.showData,
  });

  final Graph graph;
  final bool showData;
  final String path;

  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  PageController controller = PageController(
    initialPage: 0,
  );
  UniqueKey cpsKey = UniqueKey();
  int? numIter;
  dynamic focused;

  int page = 0;

  GraphType type = GraphType.stackedArea;

  void setFocused(dynamic focused_) {
    setState(() {
      focused = focused_;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              onPageChanged: (int page) {
                cpsKey = UniqueKey();
                setState(() {
                  this.page = page;
                });
              },
              controller: controller,
              children: [
                GraphWidget(
                  path: widget.path,
                  graph: widget.graph,
                  iteration: numIter,
                  setFocused: setFocused,
                ),
                SimWidget(
                  graph: widget.graph,
                  showValue: widget.showData,
                  type: type,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: CenterPageSelect(
                    key: cpsKey,
                    controller: controller,
                  ),
                ),
                if (widget.graph.sim.iter.isNotEmpty && page == 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 64, 0),
                    child: IterSliderWidget(
                      max: widget.graph.sim.iter.length,
                      onChanged: (int? pos) {
                        numIter = pos;
                        setState(() {});
                      },
                    ),
                  ),
                if (widget.graph.sim.iter.isNotEmpty && page == 1)
                  GraphTypeWidget(
                    setGraphType: (GraphType type) {
                      setState(() {
                        this.type = type;
                      });
                    },
                  ),
                if (page == 0)
                  InfoWidget(
                    graph: widget.graph,
                    iteration: numIter,
                    focused: focused,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GraphTypeWidget extends StatefulWidget {
  const GraphTypeWidget({super.key, required this.setGraphType});

  final Function setGraphType;

  @override
  State<GraphTypeWidget> createState() => _GraphTypeWidgetState();
}

class _GraphTypeWidgetState extends State<GraphTypeWidget> {
  GraphType type = GraphType.stackedArea;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              widget.setGraphType(GraphType.stackedArea);
              setState(() {
                type = GraphType.stackedArea;
              });
            },
            icon: Icon(
              Icons.stacked_bar_chart,
              shadows: (type == GraphType.stackedArea)
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 5),
                        blurRadius: 8,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
          ),
          IconButton(
            onPressed: () {
              widget.setGraphType(GraphType.stackedArea100);
              setState(() {
                type = GraphType.stackedArea100;
              });
            },
            icon: Icon(
              Icons.stacked_line_chart_rounded,
              shadows: (type == GraphType.stackedArea100)
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 5),
                        blurRadius: 8,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
          ),
          IconButton(
            onPressed: () {
              widget.setGraphType(GraphType.line);
              setState(() {
                type = GraphType.line;
              });
            },
            icon: Icon(
              Icons.line_axis_rounded,
              shadows: (type == GraphType.line)
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 5),
                        blurRadius: 8,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class IterSliderWidget extends StatefulWidget {
  const IterSliderWidget({
    super.key,
    required this.max,
    required this.onChanged,
  });

  final int max;
  final Function onChanged;

  @override
  State<IterSliderWidget> createState() => _IterSliderWidgetState();
}

class _IterSliderWidgetState extends State<IterSliderWidget> {
  bool playing = false;
  int pos = 0;
  Timer? playTimer;

  void autoPlay() {
    playTimer = Timer.periodic(const Duration(milliseconds: 500), (Timer time) {
      pos++;
      if (pos >= widget.max) {
        pos = 0;
      }
      widget.onChanged(pos);
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (playTimer != null) playTimer!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              if (playTimer != null) {
                playTimer!.cancel();
                playTimer = null;
              } else {
                autoPlay();
              }
              setState(() {
                playing = !playing;
              });
            },
            icon: playing
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
          if (widget.max < 10) Text("$pos / ${widget.max}"),
          if (widget.max >= 10)
            Slider(
              divisions: widget.max - 1,
              value: pos.toDouble(),
              min: 0,
              max: widget.max.toDouble() - 1,
              onChanged: (double value) {
                pos = value.toInt();
                widget.onChanged(pos);
                setState(() {});
              },
            ),
          IconButton(
            onPressed: () {
              if (playTimer != null) playTimer!.cancel();
              playTimer = null;
              setState(() {
                playing = false;
                pos = 0;
              });
              widget.onChanged(null);
            },
            icon: const Icon(Icons.stop_rounded),
          )
        ],
      ),
    );
  }
}

class CenterPageSelect extends StatefulWidget {
  const CenterPageSelect({super.key, required this.controller});

  final PageController controller;

  @override
  State<CenterPageSelect> createState() => _CenterPageSelectState();
}

class _CenterPageSelectState extends State<CenterPageSelect> {
  int selected = 0;

  @override
  void initState() {
    super.initState();
    if (widget.controller.page != null) {
      selected = widget.controller.page!.round();
    } else {
      selected = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              widget.controller.animateToPage(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
              setState(() {
                selected = 0;
              });
            },
            icon: Icon(
              Icons.home_filled,
              size: selected == 0 ? 30 : 15,
            ),
          ),
          IconButton(
            onPressed: () {
              widget.controller.animateToPage(
                1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
              setState(() {
                selected = 1;
              });
            },
            icon: Icon(
              Icons.auto_graph_rounded,
              size: selected == 1 ? 30 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoWidget extends StatefulWidget {
  const InfoWidget({
    super.key,
    required this.graph,
    required this.iteration,
    required this.focused,
  });

  final Graph graph;
  final int? iteration;
  final dynamic focused;

  @override
  State<InfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  Widget getNodeInfo(Node node) {
    return NodeInfoWidget(widget: widget, node: node);
  }

  Widget getEdgeInfo(MyEdge edge) {
    return EdgeInfoWidget(widget: widget, edge: edge);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.focused == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: Text("No node or edge selected")),
      );
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: (widget.focused is Node)
          ? getNodeInfo(widget.focused)
          : getEdgeInfo(widget.focused),
    );
  }
}

class NodeInfoWidget extends StatefulWidget {
  const NodeInfoWidget({
    super.key,
    required this.widget,
    required this.node,
  });

  final InfoWidget widget;
  final Node node;

  @override
  State<NodeInfoWidget> createState() => _NodeInfoWidgetState();
}

class _NodeInfoWidgetState extends State<NodeInfoWidget> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          showAll = !showAll;
        });
      },
      title: Text(
        '${widget.node.name} '
        '(${widget.node.alias}) ${showAll ? ' :' : '...'}',
      ),
      subtitle: showAll
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Birth Rate :'),
                      Text(
                          '${(widget.node.birthRate * 100).toStringAsPrecision(5)}%'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text('Death Rate : '),
                      Text(
                          '${(widget.node.deathRate * 100).toStringAsPrecision(5)}%'),
                    ],
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: (widget.widget.iteration == null)
                        ? [
                            const Text('Population :'),
                            Text(
                              widget.node.population.toStringAsExponential(),
                            ),
                          ]
                        : [
                            Text(
                                'Population (iter. ${widget.widget.iteration}) :'),
                            Text(
                              '${widget.widget.graph.sim.iter[widget.widget.iteration ?? 0][widget.widget.graph.sim.iterOrder.indexOf(
                                widget.node.alias,
                              )]}',
                            ),
                          ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text('Biosmass Per Capita : '),
                      Text(
                          '${(widget.node.biosmassPerCapita).toStringAsExponential(3)}kg'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text('Total Biomass : '),
                      Text('${(widget.node.biosmassPerCapita * ((widget.widget.iteration != null) ? widget.widget.graph.sim.iter[widget.widget.iteration ?? 0][widget.widget.graph.sim.iterOrder.indexOf(
                          widget.node.alias,
                        )] : widget.node.population)).toStringAsExponential(3)}kg'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text('Capacity Max : '),
                      Text('${widget.node.capacity.toStringAsExponential()}kg'),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class EdgeInfoWidget extends StatefulWidget {
  const EdgeInfoWidget({
    super.key,
    required this.widget,
    required this.edge,
  });

  final InfoWidget widget;
  final MyEdge edge;

  @override
  State<EdgeInfoWidget> createState() => _EdgeInfoWidgetState();
}

class _EdgeInfoWidgetState extends State<EdgeInfoWidget> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          showAll = !showAll;
        });
      },
      title: Text(
        (showAll)
            ? '${widget.widget.graph.nodes.firstWhere((e) => e.alias == widget.edge.source).name} '
                '(${widget.edge.source}) to '
                '${widget.widget.graph.nodes.firstWhere((e) => e.alias == widget.edge.target).name} '
                '(${widget.edge.target}) :'
            : '${widget.widget.graph.nodes.firstWhere((e) => e.alias == widget.edge.source).name} '
                'to '
                '${widget.widget.graph.nodes.firstWhere((e) => e.alias == widget.edge.target).name}...',
      ),
      subtitle: (showAll)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Weight : '),
                      Text('${widget.edge.weight}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text('Predation rate : '),
                      Text(
                          '${(widget.edge.predationRate * 100).toStringAsPrecision(2)}%'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text('Conversion rate : '),
                      Text(
                          '${(widget.edge.assimilationRate * 100).toStringAsPrecision(2)}%'),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
