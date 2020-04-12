import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:octopus_data/key_value_store.dart';
import 'package:octopus_data/repo/consumption_response.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:octopus_data/repo/tariff_response.dart';
import 'package:http/http.dart' as http;

@injectable
class AgileRepository {
  static const BASE_API_URL = "https://api.octopus.energy/v1";
  final KeyValueStore ac;

  AgileRepository(this.ac);

  Future<ConsumptionResponse> getConsumption() async {
    var response = await _loadConsumptionAsset();
    return ConsumptionResponse.fromJson(response);
  }

  Future<ConsumptionResponse> getMockConsumption() async {
    var response = await _loadConsumptionAsset();
    return ConsumptionResponse.fromJson(response);
  }

//todo use a higher level rest library
//todo handle non-200 errors
  Future<TariffResponse> getRates() async {
    var response = await http.get(
        '$BASE_API_URL/products/${ac.tariffCode}/electricity-tariffs/${ac.regionalTariffCode}/standard-unit-rates/');
    if (response.statusCode == 200) {
      return TariffResponse.fromJson(response.body);
    } else
      return null;
  }

  Future<TariffResponse> getRatesForDateRange(DateTime from, DateTime to,
      {int page = 1}) async {
    var response = await http.get(
        '$BASE_API_URL/products/${ac.tariffCode}/electricity-tariffs/${ac.regionalTariffCode}/standard-unit-rates/?period_from=${from.toIso8601String()}&period_to=${to.toIso8601String()}&page=$page');
    if (response.statusCode == 200) {
      return TariffResponse.fromJson(response.body);
    } else {
      return null;
    }
  }

  Future<ConsumptionResponse> getConsumptionForDateRange(
      DateTime from, DateTime to,
      {int page = 1}) async {
    String username = ac.apiKey;
    String password = '';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var headers = {'authorization': basicAuth};
    var response = await http.get(
      '$BASE_API_URL/electricity-meter-points/${ac.MPAN}/meters/${ac.MSN}/consumption/?period_from=${from.toIso8601String()}&period_to=${to.toIso8601String()}&page=$page',
      headers: headers,
    );
    if (response.statusCode == 200) {
      return ConsumptionResponse.fromJson(response.body);
    } else {
      return null;
    }
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
