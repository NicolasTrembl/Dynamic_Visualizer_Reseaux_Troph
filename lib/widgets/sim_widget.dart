import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '/logic/graph.dart';

class SimWidget extends StatefulWidget {
  const SimWidget({
    super.key,
    required this.graph,
    required this.showValue,
  });

  final Graph graph;
  final bool showValue;

  @override
  State<SimWidget> createState() => _SimWidgetState();
}

enum GraphType {
  stackedArea,
  stackedArea100,
  line,
}

class _SimWidgetState extends State<SimWidget> {
  GraphType type = GraphType.stackedArea;
  SfCartesianChart chart = const SfCartesianChart();

  CartesianSeries getSeries(
      List<String> iterOrder, List<List<int>> iter, int i) {
    String name = iterOrder[i];

    List<int> data = [];

    for (List<int> line in iter) {
      data.add(line[i]);
    }

    switch (type) {
      case GraphType.stackedArea:
        return StackedAreaSeries(
          name: name,
          legendItemText: name,
          groupName: name,
          dataLabelSettings: DataLabelSettings(
            isVisible: widget.showValue,
            useSeriesColor: true,
          ),
          dataSource: data,
          yValueMapper: (value, int index) => value,
          xValueMapper: (value, int index) => index,
        );
      case GraphType.stackedArea100:
        return StackedArea100Series(
          name: name,
          legendItemText: name,
          groupName: name,
          dataLabelSettings: DataLabelSettings(
            isVisible: widget.showValue,
            useSeriesColor: true,
          ),
          dataSource: data,
          yValueMapper: (value, int index) => value,
          xValueMapper: (value, int index) => index,
        );
      default:
        return LineSeries(
          name: name,
          dataSource: data,
          legendItemText: name,
          dataLabelSettings: DataLabelSettings(
            isVisible: widget.showValue,
            useSeriesColor: true,
          ),
          yValueMapper: (value, int index) => value,
          xValueMapper: (value, int index) => index,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SfCartesianChart(
              tooltipBehavior: TooltipBehavior(
                activationMode: ActivationMode.doubleTap,
                enable: true,
                format: 'Itération point.x : point.y',
              ),
              primaryXAxis: const CategoryAxis(
                  // title: AxisTitle(
                  //   text: "Iteration",
                  // ),
                  ),
              legend: Legend(
                isVisible: true,
                title: LegendTitle(
                  text: widget.graph.name,
                ),
              ),
              primaryYAxis: (type != GraphType.stackedArea100)
                  ? const CategoryAxis(
                      title: AxisTitle(text: "Population"),
                    )
                  : const NumericAxis(
                      maximum: 105.0,
                      title: AxisTitle(text: "Percentage"),
                    ),
              series: [
                for (int i = 0; i < widget.graph.order; i++)
                  getSeries(
                    widget.graph.sim.iterOrder,
                    widget.graph.sim.iter,
                    i,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      type = GraphType.stackedArea;
                    });
                  },
                  child: const Text("Stacked Area"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      type = GraphType.stackedArea100;
                    });
                  },
                  child: const Text("100% Stacked Area"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      type = GraphType.line;
                    });
                  },
                  child: const Text("Line"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
