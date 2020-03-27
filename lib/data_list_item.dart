import 'package:flutter/material.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/repo/repo_controller.dart';
import 'extension_functions.dart';

class DataListViewWidget extends StatelessWidget {
  final List<EnergyData> _data;

  DataListViewWidget(
    this._data, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _data.isEmpty
          ? Center(child: Text("No Data For This Date (Yet)"))
          : ListView.separated(
              itemCount: _data.length,
              reverse: true,
              itemBuilder: (context, index) {
                EnergyData item = _data[index];
                double actualTariff = RepositoryController.calculateCost(
                    item.tariffWithVat, 1, item.intervalStart.hour);

                return ListTile(
                  leading: Text(
                      "${item.intervalStart.asTimeString()} - ${item.intervalStart.add(Duration(minutes: 30)).asTimeString()}"),
                  title: Text(item.costWithVat != null
                      ? "Est Cost: ${item.costWithVat?.toStringAsFixed(2)}p"
                      : "Pending"),
                  subtitle: Text(
                      "Tariff: ${item.tariffWithVat?.toStringAsFixed(2)} p/kWh (Wholesale),\n"
                      "Tariff: ${actualTariff.toStringAsFixed(2)} p/kWh (Actual)\n"
                      "Consumption: ${item.consumption?.toStringAsFixed(2) ?? "-"} kWh"),
                  trailing: Container(
                    height: 40.0,
                    width: 10.0,
                    color: _getTariffBasedColour(actualTariff),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            ),
    );
  }
}

Color _getTariffBasedColour(double actualTariff) {
  //Super Green for < 5
  //Green for < 10p actual
  //Yellow for 10-20p
  //Amber2 for 20-30p
  //Red for > 30p
  if (actualTariff < 5.0) {
    return Colors.greenAccent;
  } else if (actualTariff <= 10.0) {
    return Colors.yellow;
  } else if (actualTariff <= 20.0) {
    return Colors.amber;
  } else if (actualTariff <= 30.0) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
