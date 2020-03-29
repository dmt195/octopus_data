import 'package:flutter/material.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/extension_functions.dart';

class SummariserWidget extends StatelessWidget {
  final List<EnergyData> data;

  SummariserWidget(this.data);

  @override
  Widget build(BuildContext context) {
    if (data == null || data.isEmpty) {
      return Container();
    }
    double totalCost = data.map((e) => e.costWithVat).toList().sum();
    double totalConsumption = data.map((e) => e.consumption).toList().sum();
    return Container(
      color: Colors.grey.withOpacity(0.5),
//      height: 40,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "Day's Cost",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("£${(totalCost / 100 + 0.21).toStringAsFixed(2)}")
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                  "Day's Usage",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${totalConsumption.toStringAsFixed(2)} kWh")
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                  "Effective Rate",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                totalConsumption != 0
                    ? Text(
                    "${(totalCost / totalConsumption).toStringAsFixed(2)} p/kWh")
                    : Text("-")
              ],
            )
          ],
        ),
      ),
    );
  }
}