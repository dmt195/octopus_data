import 'dart:convert';

import 'package:octopus_data/data/moor_database.dart';

class ConsumptionItem {
  double consumption;
  DateTime intervalStart;
  DateTime intervalEnd;

  ConsumptionItem({
    this.consumption,
    this.intervalStart,
    this.intervalEnd,
  });

  factory ConsumptionItem.fromJson(String str) =>
      ConsumptionItem.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ConsumptionItem.fromMap(Map<String, dynamic> json) => ConsumptionItem(
        consumption: json["consumption"].toDouble(),
        intervalStart: DateTime.parse(json["interval_start"]),
        intervalEnd: DateTime.parse(json["interval_end"]),
      );

  EnergyData toDbItem() {
    return EnergyData(
        intervalStart: this.intervalStart,
        consumption: this.consumption);
  }

  Map<String, dynamic> toMap() => {
        "consumption": consumption,
        "interval_start": intervalStart.toIso8601String(),
        "interval_end": intervalEnd.toIso8601String(),
      };
}
