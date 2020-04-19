import 'package:injectable/injectable.dart';
import 'package:octopus_data/bloc_main/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class KeyValueStore {
  SharedPreferences prefs;

  String apiKey;
  String MPAN;
  String MSN;
  String tariffCode;
  String regionalTariffCode;

  static const String API_KEY_KEY = "api_key";
  static const String MPAN_KEY = "mpan";
  static const String MSN_KEY = "msn";
  static const String TARIFF_CODE_KEY = "tariff";
  static const String REGIONAL_CODE_KEY = "region";

  KeyValueStore();

  Future<void> init() async {

    prefs = await SharedPreferences.getInstance();

    apiKey = prefs.getString(API_KEY_KEY) ?? "";
    MPAN = prefs.getString(MPAN_KEY) ?? "";
    MSN = prefs.getString(MSN_KEY) ?? "";
    tariffCode = prefs.getString(TARIFF_CODE_KEY) ?? "";
    regionalTariffCode = prefs.getString(REGIONAL_CODE_KEY) ?? "";
    return;
  }

  Future<void> updateCredentials(OctopusUserCredentials credentials) async {
    // API key
    this.apiKey = credentials.apiKey;
    await prefs.setString(API_KEY_KEY, apiKey);

    // Consumption details
    this.MPAN = credentials.mpan;
    this.MSN = credentials.msn;
    await prefs.setString(MPAN_KEY, credentials.mpan);
    await prefs.setString(MSN_KEY, credentials.msn);

    // Tariff details
    this.tariffCode = credentials.tariff;
    this.regionalTariffCode = credentials.regionalTariff;
    await prefs.setString(TARIFF_CODE_KEY, credentials.tariff);
    await prefs.setString(REGIONAL_CODE_KEY, credentials.regionalTariff);

  }

  Future<void> clearAllData() async {
    this.apiKey = "";
    await prefs.clear();
  }
}
