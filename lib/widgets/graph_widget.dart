import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart' as graphview;

import '/logic/save.dart';
import '/logic/graph.dart';
import '/widgets/sim_widget.dart';

class GraphWidget extends StatefulWidget {
  const GraphWidget({
    super.key,
    required this.paths,
  });

  final List<String> paths;

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  Graph? graph;
  File? dir;
  File? fileEco;
  File? fileSim;

  late StreamSubscription sub;

  // late graphview.SugiyamaConfiguration config;

  // -1 only eco, 0 both, 1 only sim

  bool canShowBoth = false;
  bool showValue = false;
  int choiceShow = 0;
  Map graphData = {};

  void getGraph(String eco, String sim) {
    graph = Graph.fromFile(eco, sim);

    buildGraph();

    setState(() {});
  }

  void buildGraph() {
    graphData.clear();

    //nodes

    var vertices = [];

    for (Node node in graph!.nodes) {
      vertices.add({
        "id": node.id,
        "tag": node.alias,
        "name": node.name,
        "alias": node.alias,
        "deathRate": node.deathRate,
        "birthRate": node.birthRate,
        "capacity": node.capacity,
        "population": node.population,
        "biosmassPerCapita": node.biosmassPerCapita,
      });
    }

    //edges

    var edges = [];
    for (MyEdge edge in graph!.edges) {
      edges.add({
        "srcId": graph!.nodes
            .firstWhere((element) => element.alias == edge.source)
            .id,
        "dstId": graph!.nodes
            .firstWhere((element) => element.alias == edge.target)
            .id,
        "edgeName": "${edge.source} → ${edge.target}",
        "weight": edge.weight,
        "ranking": 0,
        "predationRate": edge.predationRate,
        "assimilationRate": edge.assimilationRate,
      });
    }

    graphData = {
      "vertexes": vertices,
      "edges": edges,
    };
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    dir = File(widget.paths[0].replaceAll("\\output.eco", ""));
    fileEco = File(widget.paths[0]);
    fileSim = File(widget.paths[1]);

    fileEco!.readAsString().then((String eco) {
      fileSim!.readAsString().then((String sim) {
        if (sim.contains(":-")) {
          canShowBoth = true;
        }
        getGraph(eco, sim);
      });
    });

    sub = dir!.watch().listen((event) {
      print("ev" + event.toString());
      if (event.type != FileSystemEvent.modify) {
        print("You can't modify the file !!!!!!!!!!!!");
        Navigator.pop(context);
        return;
      }

      String sim = fileSim!.readAsStringSync();

      if (sim.contains(":-")) {
        canShowBoth = true;
      } else {
        canShowBoth = false;
      }
      getGraph(fileEco!.readAsStringSync(), sim);
    });
  }

  Widget vertexPanelBuilder(hoverVertex, graphview.Viewfinder viewfinder) {
    var c = viewfinder.localToGlobal(hoverVertex.cpn!.position);
    return Stack(
      children: [
        Positioned(
          left: c.x + hoverVertex.radius + 5,
          top: c.y - 20,
          child: SizedBox(
            width: 180,
            child: ColoredBox(
              color:
                  Theme.of(context).colorScheme.secondaryContainer.withOpacity(
                        .5,
                      ),
              child: ListTile(
                title: Text(
                  '${hoverVertex.data['name']} (${hoverVertex.data['alias']})',
                ),
                subtitle: Text(
                  'Death Rate: ${hoverVertex.data['deathRate']}\n'
                  'Birth Rate: ${hoverVertex.data['birthRate']}\n'
                  'Capacity: ${hoverVertex.data['capacity']}\n'
                  'Population: ${hoverVertex.data['population']}\n'
                  'Biosmass Per Capita: ${hoverVertex.data['biosmassPerCapita']}',
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget edgePanelBuilder(
      graphview.Edge hoverEdge, graphview.Viewfinder viewfinder) {
    var c = viewfinder.localToGlobal(hoverEdge.cpn!.position);
    return Stack(
      children: [
        Positioned(
          left: c.x,
          top: c.y - 20,
          child: SizedBox(
            width: 180,
            child: ColoredBox(
              color:
                  Theme.of(context).colorScheme.secondaryContainer.withOpacity(
                        .5,
                      ),
              child: ListTile(
                title: Text(
                  '${hoverEdge.data['edgeName']}',
                ),
                subtitle: Text(
                  'Weight: ${hoverEdge.data['weight']}\n'
                  'Predation Rate: ${hoverEdge.data['predationRate']}\n'
                  'Assimilation Rate: ${hoverEdge.data['assimilationRate']}',
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizer'),
        actions: [
          IconButton(
            onPressed: () {
              showValue = !showValue;
              setState(() {});
            },
            icon: const Icon(Icons.text_snippet_outlined),
          ),
          IconButton(
            onPressed: () {
              choiceShow++;
              if (choiceShow > 1) {
                choiceShow = -1;
              }
              setState(() {});
            },
            icon: const Icon(Icons.view_agenda_outlined),
          ),
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
      body: graphData.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.cyan,
              ),
            )
          : SizedBox.expand(
              child: Stack(
                children: [
                  Positioned(
                    // duration: const Duration(milliseconds: 500),
                    width: MediaQuery.of(context).size.width,
                    bottom: (choiceShow == 1)
                        ? MediaQuery.of(context).size.height
                        : (choiceShow == 0)
                            ? MediaQuery.of(context).size.height * 1 / 4
                            : 0,
                    top: (choiceShow == 1)
                        ? -MediaQuery.of(context).size.height
                        : 0,
                    child: graphview.FlutterGraphWidget(
                      data: graphData,
                      convertor: graphview.MapConvertor(),
                      algorithm: graphview.ForceDirected(
                        decorators: [
                          graphview.CoulombDecorator(),
                          graphview.HookeBorderDecorator(),
                          graphview.HookeDecorator(),
                          graphview.CoulombCenterDecorator(),
                          graphview.HookeCenterDecorator(),
                          graphview.ForceDecorator(),
                          graphview.ForceMotionDecorator(),
                          graphview.TimeCounterDecorator(),
                        ],
                      ),
                      options: graphview.Options()
                        ..backgroundBuilder = ((context) => Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                            ))
                        ..showText = true
                        ..textGetter = ((vertex) => vertex.data['name'])
                        ..panelDelay = const Duration(milliseconds: 250)
                        ..graphStyle = (graphview.GraphStyle()

                          // tagColor is prior to tagColorByIndex. use vertex.tags to get color
                          ..tagColor = {'tag8': Colors.orangeAccent.shade200}
                          ..tagColorByIndex = [
                            Colors.red.shade200,
                            Colors.orange.shade200,
                            Colors.yellow.shade200,
                            Colors.green.shade200,
                            Colors.blue.shade200,
                            Colors.blueAccent.shade200,
                            Colors.purple.shade200,
                            Colors.pink.shade200,
                            Colors.blueGrey.shade200,
                            Colors.deepOrange.shade200,
                          ])
                        ..vertexPanelBuilder = vertexPanelBuilder
                        ..edgePanelBuilder = edgePanelBuilder,
                    ),
                  ),
                  Positioned(
                    // duration: const Duration(milliseconds: 500),
                    width: MediaQuery.of(context).size.width,
                    top: (choiceShow == -1)
                        ? MediaQuery.of(context).size.height
                        : (choiceShow == 0)
                            ? MediaQuery.of(context).size.height / 2
                            : 0,
                    bottom: (choiceShow == -1)
                        ? -MediaQuery.of(context).size.height
                        : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      child: SimWidget(
                        graph: graph!,
                        showValue: showValue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
