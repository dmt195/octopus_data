import 'package:flutter/material.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GraphWidget extends StatelessWidget {
  final List<EnergyData> data;

  GraphWidget(this.data);

  @override
  Widget build(BuildContext context) {
    if (data == null || data.isEmpty) {
      return Container();
    }
    return Container(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: charts.TimeSeriesChart(
          _createSeriesData(data),
          animate: true,
          defaultRenderer: charts.LineRendererConfig(),
        ),
      ),
    );
  }
}

List<charts.Series<EnergyData, DateTime>> _createSeriesData(List<EnergyData> data) {
  return [charts.Series<EnergyData, DateTime>(
    id: 'Wholesale Rate',
    colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    domainFn: (EnergyData energy, _) => energy.intervalStart,
    measureFn: (EnergyData energy, _) => energy.tariffWithVat,
    data: data,
  ),
    charts.Series<EnergyData, DateTime>(
      id: 'Cost',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (EnergyData energy, _) => energy.intervalStart,
      measureFn: (EnergyData energy, _) => energy.costWithVat,
      data: data,
    ),
  ];
}
