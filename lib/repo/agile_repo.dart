import 'dart:convert';

import 'package:octopus_data/repo/consumption_response.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:octopus_data/repo/tariff_response.dart';
import 'package:http/http.dart' as http;

Future<ConsumptionResponse> getConsumption() async {
  var response = await _loadConsumptionAsset();
  return ConsumptionResponse.fromJson(response);
}

Future<ConsumptionResponse> getMockConsumption() async {
  var response = await _loadConsumptionAsset();
  return ConsumptionResponse.fromJson(response);
}

Future<TariffResponse> getRates() async {
  var response = await http.get(
      'https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-AGILE-18-02-21-L/standard-unit-rates/');
  if (response.statusCode == 200) {
    return TariffResponse.fromJson(response.body);
  } else
    return null;
}

Future<TariffResponse> getRatesForDateRange(DateTime from, DateTime to,
    {int page = 1}) async {
  var response = await http.get(
      'https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-AGILE-18-02-21-L/standard-unit-rates/?period_from=${from.toIso8601String()}&period_to=${to.toIso8601String()}&page=$page');
  if (response.statusCode == 200) {
    return TariffResponse.fromJson(response.body);
  } else {
    print(
        "Rates response returned ${response.statusCode} (${response.reasonPhrase}).");
    return null;
  }
}

Future<ConsumptionResponse> getConsumptionForDateRange(
    DateTime from, DateTime to,
    {int page = 1}) async {
  String username = 'sk_live_twFZlNhCm3iwKvjO05igG21H';
  String password = '';
  String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  var headers = {'authorization': basicAuth};
  var response = await http.get(
    'https://api.octopus.energy/v1/electricity-meter-points/2200017071783/meters/17P0117467/consumption/?period_from=${from.toIso8601String()}&period_to=${to.toIso8601String()}&page=$page',
    headers: headers,
  );
  if (response.statusCode == 200) {
    return ConsumptionResponse.fromJson(response.body);
  } else {
    print(
        "Consumption response returned ${response.statusCode} (${response.reasonPhrase}).");
    return null;
  }
}

Future<TariffResponse> getMockRates() async {
  var response = await _loadTariffAsset();
  return TariffResponse.fromJson(response);
}

Future<String> _loadConsumptionAsset() async {
  return await rootBundle
      .loadString('assets/data/sample_consumption_result.json');
}

Future<String> _loadTariffAsset() async {
  return await rootBundle.loadString('assets/data/sample_tariff_result.json');
}
