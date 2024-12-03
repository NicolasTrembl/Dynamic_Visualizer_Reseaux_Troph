import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '/logic/graph.dart';

class SimWidget extends StatefulWidget {
  const SimWidget({
    super.key,
    required this.graph,
    required this.showValue,
    required this.type,
  });

  final Graph graph;
  final bool showValue;
  final GraphType type;

  @override
  State<SimWidget> createState() => _SimWidgetState();
}

enum GraphType {
  stackedArea,
  stackedArea100,
  line,
}

class _SimWidgetState extends State<SimWidget> {
  SfCartesianChart chart = const SfCartesianChart();

  CartesianSeries getSeries(
      List<String> iterOrder, List<List<int>> iter, int i) {
    String name = iterOrder[i];

    List<int> data = [];

    for (List<int> line in iter) {
      data.add(line[i]);
    }

    switch (widget.type) {
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
    if (widget.graph.sim.iter.isEmpty) {
      return const Center(
        child: Text("No simulation data"),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 128),
      color: Theme.of(context).colorScheme.surface,
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
              primaryXAxis: const CategoryAxis(),
              legend: Legend(
                isVisible: true,
                title: LegendTitle(
                  text: widget.graph.name,
                ),
              ),
              primaryYAxis: (widget.type != GraphType.stackedArea100)
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
        ],
      ),
    );
  }
}
