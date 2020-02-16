// To parse this JSON data, do
//
//     final consumption = consumptionFromJson(jsonString);

import 'dart:convert';
import 'package:octopus_data/models/consumption_item.dart';

class ConsumptionResponse {
  int count;
  String next;
  String previous;
  List<ConsumptionItem> results;

  ConsumptionResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory ConsumptionResponse.fromJson(String str) => ConsumptionResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ConsumptionResponse.fromMap(Map<String, dynamic> json) => ConsumptionResponse(
    count: json["count"],
    next: json["next"],
    previous: json["previous"],
    results: List<ConsumptionItem>.from(json["results"].map((x) => ConsumptionItem.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "count": count,
    "next": next,
    "previous": previous,
    "results": List<dynamic>.from(results.map((x) => x.toMap())),
  };
}

