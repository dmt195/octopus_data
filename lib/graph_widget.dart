import 'package:flutter/material.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GraphWidget extends StatefulWidget {
  final List<EnergyData> data;

  GraphWidget(this.data);

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  bool isExpanded;

  @override
  void initState() {
    isExpanded = false;
    super.initState();
  }

  void _toggleExpansion() {
    print("In toggleExpansion");
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null || widget.data.isEmpty) {
      return Container();
    }
    return InkWell(
      onTap: () => _toggleExpansion(),
      child: AnimatedContainer(
        height: isExpanded ? 300 : 100,
        duration: Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IgnorePointer(
            ignoring: true,
            child: charts.TimeSeriesChart(
              _createSeriesData(widget.data),
              animate: false,
              defaultRenderer: charts.LineRendererConfig(),
              primaryMeasureAxis: _darkLightModeAxisSpecPrimary(),
              domainAxis: _darkLightModeAxisSpecTimeSeries(),
            ),
          ),
        ),
      ),
    );
  }

  _darkLightModeAxisSpecPrimary() {
    return charts.NumericAxisSpec(
      renderSpec: charts.SmallTickRendererSpec(
        lineStyle: charts.LineStyleSpec(
          color: getColorForTheme(context),
        ),
        labelStyle: charts.TextStyleSpec(
          color: getColorForTheme(context),
        ),
      ),
    );
  }

  _darkLightModeAxisSpecTimeSeries() {
    return charts.DateTimeAxisSpec(
      renderSpec: charts.SmallTickRendererSpec(
        lineStyle: charts.LineStyleSpec(
          color: getColorForTheme(context),
        ),
        labelStyle: charts.TextStyleSpec(
          color: getColorForTheme(context),
          fontSize: 8,
        ),
      ),
    );
  }
}

charts.Color getColorForTheme(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? charts.Color.white
      : charts.Color.black;
}

List<charts.Series<EnergyData, DateTime>> _createSeriesData(
    List<EnergyData> data) {
  return [
    charts.Series<EnergyData, DateTime>(
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
