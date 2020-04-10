import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class KeyValueStore {
  SharedPreferences prefs;

  String apiKey;
  String MPAN;
  String MSN;
  String tariffCode;
  String regionalTariffCode;
  String consumptionCurl;

  String tariffCurl;
  static const String CONSUMPTION_CURL_KEY = "consumptionCurl";
  static const String TARIFF_CURL_KEY = "tariffCurl";
  static const String API_KEY_KEY = "api_key";
  static const String MPAN_KEY = "mpan";
  static const String MSN_KEY = "msn";
  static const String TARIFF_CODE_KEY = "tariff";
  static const String REGIONAL_CODE_KEY = "region";

  KeyValueStore();

  Future<void> init() async {

    prefs = await SharedPreferences.getInstance();

    consumptionCurl = prefs.getString(CONSUMPTION_CURL_KEY) ?? "";
    tariffCurl = prefs.getString(TARIFF_CURL_KEY) ?? "";

    apiKey = prefs.getString(API_KEY_KEY) ?? "";
    MPAN = prefs.getString(MPAN_KEY) ?? "";
    MSN = prefs.getString(MSN_KEY) ?? "";
    tariffCode = prefs.getString(TARIFF_CODE_KEY) ?? "";
    regionalTariffCode = prefs.getString(REGIONAL_CODE_KEY) ?? "";
    return;
  }

  Future<void> upDateCurls(String consumptionCurl, String tariffCurl) async {
    this.consumptionCurl = consumptionCurl;
    this.tariffCurl = tariffCurl;
    await prefs.setString(CONSUMPTION_CURL_KEY, consumptionCurl);
    await prefs.setString(TARIFF_CURL_KEY, tariffCurl);
  }

  Future<void> saveConsumptionCredentials(
      String apiKey, String mPAN, String serialNo) async {
    this.apiKey = apiKey;
    this.MPAN = mPAN;
    this.MSN = serialNo;
    await prefs.setString(API_KEY_KEY, apiKey);
    await prefs.setString(MPAN_KEY, mPAN);
    await prefs.setString(MSN_KEY, serialNo);
  }

  Future<void> saveTariffCredentials(
      String tariff, String regionalTariff) async {
    this.tariffCode = tariff;
    this.regionalTariffCode = regionalTariff;
    await prefs.setString(TARIFF_CODE_KEY, tariff);
    await prefs.setString(REGIONAL_CODE_KEY, regionalTariff);
  }

  Future<void> clearAllData() async {
    await prefs.clear();
  }
}
