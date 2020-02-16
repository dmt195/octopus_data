import 'dart:convert';

import 'package:octopus_data/data/moor_database.dart';

class TariffItem {
  double valueExcVat;
  double valueIncVat;
  DateTime validFrom;
  DateTime validTo;

  TariffItem({
    this.valueExcVat,
    this.valueIncVat,
    this.validFrom,
    this.validTo,
  });

  factory TariffItem.fromJson(String str) =>
      TariffItem.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TariffItem.fromMap(Map<String, dynamic> json) => TariffItem(
        valueExcVat: json["value_exc_vat"].toDouble(),
        valueIncVat: json["value_inc_vat"].toDouble(),
        validFrom: DateTime.parse(json["valid_from"]),
        validTo: DateTime.parse(json["valid_to"]),
      );

  EnergyData toDbItem() {
    return EnergyData(
        intervalStart: this.validFrom,
        intervalEnd: this.validTo,
        tariffExVat: this.valueExcVat,
        tariffWithVat: this.valueIncVat);
  }

  Map<String, dynamic> toMap() => {
        "value_exc_vat": valueExcVat,
        "value_inc_vat": valueIncVat,
        "valid_from": validFrom.toIso8601String(),
        "valid_to": validTo.toIso8601String(),
      };
}
