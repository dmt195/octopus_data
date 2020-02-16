// To parse this JSON data, do
//
//     final tariffResponse = tariffResponseFromJson(jsonString);

import 'dart:convert';

import 'package:octopus_data/models/tariff_item.dart';

class TariffResponse {
  int count;
  String next;
  dynamic previous;
  List<TariffItem> results;

  TariffResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory TariffResponse.fromJson(String str) => TariffResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TariffResponse.fromMap(Map<String, dynamic> json) => TariffResponse(
    count: json["count"],
    next: json["next"],
    previous: json["previous"],
    results: List<TariffItem>.from(json["results"].map((x) => TariffItem.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "count": count,
    "next": next,
    "previous": previous,
    "results": List<dynamic>.from(results.map((x) => x.toMap())),
  };
}

