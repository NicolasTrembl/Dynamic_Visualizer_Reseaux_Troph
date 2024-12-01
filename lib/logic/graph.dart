class Node {
  Node({
    required this.name,
    required this.alias,
    required this.deathRate,
    required this.birthRate,
    required this.capacity,
    required this.population,
    required this.biosmassPerCapita,
    this.id,
  });

  String name;
  String alias;
  double deathRate;
  double birthRate;
  double capacity;
  double biosmassPerCapita;
  int population;
  int? id;

  factory Node.fromFile(String line) {
    String name = line.split("(")[0].trim();
    String alias = line.split("(")[1].split(")")[0].trim();
    double deathRate = double.parse(
            line.split("{")[1].split("/")[0].trim().replaceAll("%", "")) /
        100;
    double birthRate = double.parse(
            line.split("{")[1].split("/")[1].trim().replaceAll("%", "")) /
        100;
    double capacity = double.parse(
        line.split("{")[1].split("/")[2].trim().replaceAll("%", ""));

    int population =
        int.parse(line.split("{")[1].split("/")[3].replaceAll("}", "").trim());

    double biosmass = double.parse(
        line.split("{")[1].split("/")[4].replaceAll("}", "").trim());

    int? id;
    if (line.contains("[")) {
      id = int.parse(line.split("[")[1].split("]")[0].trim());
    }

    return Node(
      name: name,
      alias: alias,
      deathRate: deathRate,
      birthRate: birthRate,
      capacity: capacity,
      biosmassPerCapita: biosmass,
      population: population,
      id: id,
    );
  }
}

class MyEdge {
  MyEdge({
    required this.source,
    required this.target,
    required this.weight,
    required this.predationRate,
    required this.assimilationRate,
  });

  String source;
  String target;
  int weight;
  double predationRate;
  double assimilationRate;

  factory MyEdge.fromFile(String v1, String v2) {
    String sourceAlias = v1.trim();
    String targetAlias = v2.split("{")[0].trim();
    double predRate = double.parse(v2.split("{")[1].split("/")[0].trim());
    double convRate =
        double.parse(v2.split("{")[1].split("/")[1].split("}")[0].trim());
    int weight = 1;
    if (v2.contains("[")) {
      weight = int.parse(v2.split("[")[1].split("]")[0].trim());
    }

    return MyEdge(
      source: sourceAlias,
      target: targetAlias,
      weight: weight,
      predationRate: predRate,
      assimilationRate: convRate,
    );
  }
}

class Sim {
  Sim({
    required this.numb,
    required this.iter,
    required this.iterOrder,
  });

  final int numb;
  final List<List<int>> iter;
  final List<String> iterOrder;
}

class Graph {
  Graph({
    required this.name,
    required this.params,
    required this.nodes,
    required this.edges,
    required this.sim,
  });

  int lastId = 0;

  String name;
  final List<String> params;
  final List<Node> nodes;
  final List<MyEdge> edges;
  final Sim sim;

  get order => nodes.length;

  get size => edges.length;

  get numbIter => sim.numb;

  factory Graph.fromFile(String fileContent, String simContent) {
    String name = "";
    int? order;
    // ignore: unused_local_variable
    int? size;
    List<String> params = [];
    List<Node> nodes = [];
    List<MyEdge> edges = [];
    int id = 0;

    List<String> splitted = fileContent.split("\n");

    for (String line in splitted) {
      if (line.startsWith("#")) {
        // Param
        params.add(line.replaceAll("#", "").trim());
      } else if (line.startsWith("--")) {
        // Comment
        continue;
      } else if (line.contains("->")) {
        // MyEdge
        List<String> vBarSplit = line.split("|");

        for (String vBar in vBarSplit) {
          List<String> v = vBar.split("->");
          MyEdge edge = MyEdge.fromFile(v[0], v[1]);
          edges.add(edge);
        }
      } else if (name.isEmpty && line.trim().isNotEmpty) {
        name = line.trim();
      } else if (line.trim().isNotEmpty &&
          int.tryParse(line.replaceAll(" ", "")) != null) {
        List<String> split = line.trim().split(" ");
        if (split.length == 2) {
          // order and size
          order = int.parse(split[0]);
          size = int.parse(split[1]);
        } else {
          if (order != null) {
            size = int.parse(line.trim());
          } else {
            order = int.parse(line.trim());
          }
        }
      } else if (line.trim().isNotEmpty) {
        for (String node in line.trim().split("|")) {
          Node newNode = Node.fromFile(node);
          if (params.contains("autoID")) {
            newNode.id = id;
            id++;
          }
          nodes.add(newNode);
        }
      }
    }

    bool passed = false;
    List<String> simSplit = simContent.split("\n");

    int count = 0;
    List<List<int>> iter = [];

    List<String> iterOrder = [];

    for (String line in simSplit) {
      if (line.startsWith("#")) {
        // Param
        params.add(line.replaceAll("#", "").trim());
        continue;
      }

      if (line.contains(":-")) {
        passed = true;
        continue;
      }
      if (!passed) {
        if (line.contains("|")) {
          iterOrder = line.split("|");
          iterOrder
            ..removeRange(0, 2)
            ..removeLast();
        }
        continue;
      }

      if (line.trim().isEmpty) {
        continue;
      }

      if (line.contains("|")) {
        count++;

        List<String> cells = line.split("|")
          ..removeRange(0, 2)
          ..removeLast();

        List<int> iterLine = [];

        for (String cell in cells) {
          iterLine.add(int.parse(cell.trim()));
        }

        iter.add(iterLine);
      }
    }

    Sim sim = Sim(numb: count, iter: iter, iterOrder: iterOrder);

    return Graph(
      name: name,
      params: params,
      nodes: nodes,
      edges: edges,
      sim: sim,
    )..lastId = id;
  }
}
