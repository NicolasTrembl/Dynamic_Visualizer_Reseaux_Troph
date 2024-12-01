import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:file_picker/file_picker.dart';

import '/logic/graph.dart';

class Export {
  void exportToCsv(Graph? graph) async {
    if (graph == null) {
      return;
    }

    String csv = "Count,${graph.sim.iterOrder.join(",")}\n";

    for (int i = 0; i < graph.sim.iter.length; i++) {
      csv += "$i,${graph.sim.iter[i].join(",")}\n";
    }

    String? result = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ["csv"],
      dialogTitle: "Save file",
    );

    if (result != null) {
      if (!result.endsWith(".csv")) {
        result += ".csv";
      }
      File file = File(result);
      file.writeAsString(csv);
    }
  }

  void exportToJson(Graph? graph) async {
    if (graph == null) {
      return;
    }

    String json = "{\n"
        "  \"name\": \"${graph.name}\",\n"
        "  \"params\": [${graph.params.map((e) => "\"$e\"").toList().join(",")}],\n"
        "  \"nodes\": [\n";

    for (Node node in graph.nodes) {
      json += "    {\n"
          "      \"name\": \"${node.name}\",\n"
          "      \"alias\": \"${node.alias}\",\n"
          "      \"deathRate\": ${node.deathRate},\n"
          "      \"birthRate\": ${node.birthRate},\n"
          "      \"capacity\": ${node.capacity},\n"
          "      \"population\": ${node.population}\n"
          "    }";
      if (graph.nodes.indexOf(node) != graph.nodes.length - 1) {
        json += ",\n";
      } else {
        json += "\n";
      }
    }

    json += "  ],\n"
        "  \"edges\": [\n";

    for (MyEdge edge in graph.edges) {
      json += "    {\n"
          "      \"source\": \"${edge.source}\",\n"
          "      \"target\": \"${edge.target}\",\n"
          "      \"weight\": ${edge.weight},\n"
          "      \"predationRate\": ${edge.predationRate},\n"
          "      \"assimilationRate\": ${edge.assimilationRate}\n"
          "    }";
      if (graph.edges.indexOf(edge) != graph.edges.length - 1) {
        json += ",\n";
      } else {
        json += "\n";
      }
    }

    json += "  ],\n"
        "  \"sim\": {\n"
        "    \"numb\": ${graph.sim.numb},\n"
        "    \"iter\": [\n";

    for (List<int> iter in graph.sim.iter) {
      json += "      [${iter.join(", ")}]";
      if (graph.sim.iter.indexOf(iter) != graph.sim.iter.length - 1) {
        json += ",\n";
      } else {
        json += "\n";
      }
    }

    json += "    ],\n"
        "    \"iterOrder\": [${graph.sim.iterOrder.map((e) => "\"${e.trim()}\"").join(",")}]\n"
        "  }\n"
        "}";

    String? result = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ["json"],
      dialogTitle: "Save file",
    );

    if (result != null) {
      if (!result.endsWith(".json")) {
        result += ".json";
      }
      File file = File(result);
      file.writeAsString(json);
    }
  }

  void exportToDot(Graph? graph) async {
    if (graph == null) {
      return;
    }

    String dot = "digraph ${graph.name.replaceAll(" ", "_")} {\n";

    dot += "  label=\"${graph.name}\";\n";

    for (Node node in graph.nodes) {
      dot += "  ${node.alias} [label=\"${node.name}\"];\n";
    }

    for (MyEdge edge in graph.edges) {
      dot += "  ${edge.source} -> ${edge.target} [label=\"${edge.weight}\"];\n";
    }

    dot += "}";

    String? result = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ["dot", "gv"],
      dialogTitle: "Save file",
    );

    if (result != null) {
      if (!result.endsWith(".dot") && !result.endsWith(".gv")) {
        result += ".gv";
      }
      File file = File(result);
      file.writeAsString(dot);
    }
  }

  void exportToGrahpml(Graph? graph) async {
    if (graph == null) {
      return;
    }

    String graphml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        "<graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\"\n"
        "         xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
        "         xsi:schemaLocation=\"http://graphml.graphdrawing.org/xmlns\n"
        "         http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd\">\n"
        "  <graph id=\"G\" edgedefault=\"directed\">\n";

    // define attributes
    graphml +=
        "    <key id=\"name\" for=\"node\" attr.name=\"name\" attr.type=\"string\"/>\n"
        "    <key id=\"deathRate\" for=\"node\" attr.name=\"deathRate\" attr.type=\"double\"/>\n"
        "    <key id=\"birthRate\" for=\"node\" attr.name=\"birthRate\" attr.type=\"double\"/>\n"
        "    <key id=\"capacity\" for=\"node\" attr.name=\"capacity\" attr.type=\"int\"/>\n"
        "    <key id=\"population\" for=\"node\" attr.name=\"population\" attr.type=\"int\"/>\n"
        "    <key id=\"weight\" for=\"edge\" attr.name=\"weight\" attr.type=\"int\"/>\n"
        "    <key id=\"predationRate\" for=\"edge\" attr.name=\"predationRate\" attr.type=\"double\"/>\n"
        "    <key id=\"assimilationRate\" for=\"edge\" attr.name=\"assimilationRate\" attr.type=\"double\"/>\n";

    for (Node node in graph.nodes) {
      graphml += "    <node id=\"${node.alias}\">\n"
          "      <data key=\"name\">${node.name}</data>\n"
          "      <data key=\"deathRate\">${node.deathRate}</data>\n"
          "      <data key=\"birthRate\">${node.birthRate}</data>\n"
          "      <data key=\"capacity\">${node.capacity}</data>\n"
          "      <data key=\"population\">${node.population}</data>\n"
          "    </node>\n";
    }

    for (MyEdge edge in graph.edges) {
      graphml +=
          "    <edge source=\"${edge.source}\" target=\"${edge.target}\">\n"
          "      <data key=\"weight\">${edge.weight}</data>\n"
          "      <data key=\"predationRate\">${edge.predationRate}</data>\n"
          "      <data key=\"assimilationRate\">${edge.assimilationRate}</data>\n"
          "    </edge>\n";
    }

    graphml += "  </graph>\n"
        "</graphml>";

    String? result = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ["graphml"],
      dialogTitle: "Save file",
    );

    if (result != null) {
      if (!result.endsWith(".graphml")) {
        result += ".graphml";
      }
      File file = File(result);
      file.writeAsString(graphml);
    }
  }

  void exportToGexf(Graph? graph) async {
    if (graph == null) {
      return;
    }

    String gexf = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        "<gexf xmlns=\"http://www.gexf.net/1.2draft\"\n"
        "      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
        "      xsi:schemaLocation=\"http://www.gexf.net/1.2draft\n"
        "      http://www.gexf.net/1.2draft/gexf.xsd\"\n"
        "      version=\"1.2\">\n"
        "  <graph mode=\"static\" defaultedgetype=\"directed\">\n";

    gexf += "    <attributes class=\"node\">\n"
        "      <attribute id=\"0\" title=\"name\" type=\"string\"/>\n"
        "      <attribute id=\"1\" title=\"deathRate\" type=\"double\"/>\n"
        "      <attribute id=\"2\" title=\"birthRate\" type=\"double\"/>\n"
        "      <attribute id=\"3\" title=\"capacity\" type=\"int\"/>\n"
        "      <attribute id=\"4\" title=\"population\" type=\"int\"/>\n"
        "    </attributes>\n"
        "    <attributes class=\"edge\">\n"
        "      <attribute id=\"5\" title=\"weight\" type=\"int\"/>\n"
        "      <attribute id=\"6\" title=\"predationRate\" type=\"double\"/>\n"
        "      <attribute id=\"7\" title=\"assimilationRate\" type=\"double\"/>\n"
        "    </attributes>\n";

    for (Node node in graph.nodes) {
      gexf += "    <node id=\"${node.alias}\" label=\"${node.alias}\">\n"
          "      <attvalues>\n"
          "        <attvalue for=\"0\" value=\"${node.name}\"/>\n"
          "        <attvalue for=\"1\" value=\"${node.deathRate}\"/>\n"
          "        <attvalue for=\"2\" value=\"${node.birthRate}\"/>\n"
          "        <attvalue for=\"3\" value=\"${node.capacity}\"/>\n"
          "        <attvalue for=\"4\" value=\"${node.population}\"/>\n"
          "      </attvalues>\n"
          "    </node>\n";
    }

    for (MyEdge edge in graph.edges) {
      gexf +=
          "    <edge source=\"${edge.source}\" target=\"${edge.target}\" weight=\"${edge.weight}\">\n"
          "      <attvalues>\n"
          "        <attvalue for=\"5\" value=\"${edge.weight}\"/>\n"
          "        <attvalue for=\"6\" value=\"${edge.predationRate}\"/>\n"
          "        <attvalue for=\"7\" value=\"${edge.assimilationRate}\"/>\n"
          "      </attvalues>\n"
          "    </edge>\n";
    }

    gexf += "  </graph>\n"
        "</gexf>";

    String? result = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ["gexf"],
      dialogTitle: "Save file",
    );

    if (result != null) {
      if (!result.endsWith(".gexf")) {
        result += ".gexf";
      }
      File file = File(result);
      file.writeAsString(gexf);
    }
  }

  void exportToXlsx(Graph? graph) async {
    if (graph == null) {
      return;
    }

    final excel = xl.Excel.createExcel();

    final xl.Sheet sheet = excel[graph.name];
    excel.delete('Sheet1');

    sheet.appendRow(
      [xl.TextCellValue("Count")] +
          graph.sim.iterOrder.map((e) => xl.TextCellValue(e)).toList(),
    );

    for (int i = 0; i < graph.sim.iter.length; i++) {
      sheet.appendRow([xl.IntCellValue(i)] +
          graph.sim.iter[i].map((e) => xl.IntCellValue(e)).toList());
    }

    String? result = await FilePicker.platform.saveFile(
      allowedExtensions: ["xlsx"],
      dialogTitle: "Save file",
    );

    if (result != null) {
      if (!result.endsWith(".xlsx")) {
        result += ".xlsx";
      }

      File exFile = File(result);

      var fileBytes = excel.save(fileName: result);
      if (fileBytes == null) {
        exFile.deleteSync();
        return;
      }

      exFile
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }
}
