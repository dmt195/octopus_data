import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:octopus_data/key_value_store.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/repo/agile_repo.dart';
import 'bloc.dart';
import 'package:html/parser.dart' as parser;

class MainBloc extends Bloc<MainEvent, MainState> {
  @override
  MainState get initialState {
    return InitialMainState();
  }

  KeyValueStore keyValueStore;
  AgileRepository ar;
  AppDatabase db;
  DateTime dayOfInterest;
  StreamSubscription<List<EnergyData>> subSub;

  MainBloc(this.db) {
    init();
  }

  init() async {
    dayOfInterest = DateTime.now();
    keyValueStore = await KeyValueStore();
    await keyValueStore.init();
    add(SavedDataReadyEvent());
    getDataAndListen();
  }

  void getDataAndListen() {
    if (subSub != null) {
      subSub.cancel();
//      print("Cancelling old DB query sub");
    }
    var dbSub = db.watchAllEnergyData(dayOfInterest);
//    print(
//        "Subscribing to DB query for new date ${dayOfInterest.toIso8601String()}");
    subSub = dbSub.listen((List<EnergyData> data) {
//      print("DB result changed with ${data.length} entries");
      add(DataAvailableEvent(data));
    });
  }

  @override
  Future<void> close() {
    subSub.cancel();
    return super.close();
  }

  @override
  Stream<MainState> mapEventToState(
    MainEvent event,
  ) async* {
    print("In mapEventToState with $event incoming...");
    if (event is DownloadRequestEvent) {
      yield DataRequestState();
      print("Emitting DataRequestState");
      await getAndSaveAllTariffData();
      await getAndSaveAllConsumptionData();
      await findCompletableChargeMatchesAndAddToDb();
      yield CompletedFetchState();
      getDataAndListen(); //this feels wrong!
      print("Emitting CompletedFetchState");
    } else if (event is SavedDataReadyEvent) {
      // if empty then fire the settings page event
      if (keyValueStore.apiKey.isEmpty) {
        print("api key is empty");
        yield SettingsRequiredState();
        print("Emitting SettingsRequiredState");
      } else {
        print("api key is present - getting AgileRepo instance");
        // ready the repos with their appropriate settings
        ar = AgileRepository(keyValueStore);
        add(DownloadRequestEvent());
      }
    } else if (event is DataAvailableEvent) {
      yield DataAvailableState(event.data);
      print(
          "Emitting DataAvailableState (with data of ${event.data.length} elements)");
    } else if (event is DateChosenEvent) {
      dayOfInterest = event.date;
      getDataAndListen();
    } else if (event is PreferencesSavedEvent) {
      keyValueStore.updateCredentials(event.credentials);
      add(SavedDataReadyEvent());
    } else if (event is ClearAllDataEvent) {
      await keyValueStore.clearAllData();
      await db.clearAllData();
      yield SettingsRequiredState();
      print("Emitting SettingsRequiredState");
    } else if (event is DocumentProcessRequestEvent) {
      CredentialParserResult parser =
          await parseDevPageDoc(event.webDocumentAsString);
      if (parser.success) {
        print("Parsing successful");
        print("Emitting ShowCredentialsState");
        yield ShowCredentialsState(parser.credentials);
        add(PreferencesSavedEvent(parser.credentials));
      } else {
        print("Parsing failed. Incoming data: ${event.webDocumentAsString}");
      }
    } else if (event is WebNavEvent) {
      print("WebNavEvent with ${event.url}");
      if (event.url == "https://octopus.energy/dashboard/developer/") {
        print("Emitting DevPageForegroundedState");
        yield DevPageForegroundedState();
      }
    }
  }

  Future<void> getAndSaveAllTariffData() async {
    DateTime tomorrow = DateTime.now().add(Duration(days: 2));
    DateTime lastTariffEntry = await db.getLatestTariff();
    //if the last entry doesn't exist then chose this time last year
    if (lastTariffEntry?.isBefore(tomorrow) ?? true) {
      //last entry is earlier than this time tomorrow
      int page = 1;
      bool isMoreResults = true;
      //iterate over all the results, making an api call each time
      while (isMoreResults) {
//        print("Making tariff API call (page = $page)");
        var response = await ar.getRatesForDateRange(
            lastTariffEntry ?? tomorrow.subtract(Duration(days: 30)), tomorrow,
            page: page);
        if (response != null && response.count > 0) {
//          print("Inserting ${response.count} items into Tariffs Table");
          db.transaction(() async {
            response.results.forEach((result) async {
              await db.insertTariffData(result.toDbItem());
            });
          });
        }
        isMoreResults = response != null && response.next != null;
        page++;
      }
    }
  }

  Future<void> getAndSaveAllConsumptionData() async {
    DateTime today = DateTime.now();
    DateTime lastConsumptionEntry = await db.getDateOfLatestConsumptionData();
    //if the last entry doesn't exist then chose this time last year
    if (lastConsumptionEntry?.isBefore(today) ?? true) {
      //last entry is earlier than this time tomorrow
      int page = 1;
      bool isMoreResults = true;
      //iterate over all the results, making an api call each time
      while (isMoreResults) {
        var response = await ar.getConsumptionForDateRange(
            lastConsumptionEntry ?? today.subtract(Duration(days: 30)), today,
            page: page);
        if (response != null && response.count > 0) {
//          print("Inserting ${response.count} items into Consumption Table");
          db.transaction(() async {
            response.results.forEach((result) async {
              await db.updateWithConsumptionData(result.toDbItem());
            });
          });
        }
        isMoreResults = response != null && response.next != null;
        page++;
      }
    }
  }

  Future<void> findCompletableChargeMatchesAndAddToDb(
      {bool recalculate = false}) async {
    //find all data where tariff and consumption values exist but where no cost data exists
    List<EnergyData> dbResponseData = await db.getUncostedEntries();
    List<EnergyData> dataToUpdate;
    if (dbResponseData == null || dbResponseData.isEmpty) {
      return null;
    }

    if (!recalculate) {
      dataToUpdate =
          dbResponseData.where((e) => e.costWithVat == null).toList();
    } else {
      dataToUpdate = dbResponseData;
    }

    db.transaction(() async {
      dataToUpdate.forEach((e) async {
        await db.updateWithCostData(EnergyData(
            intervalStart: e.intervalStart, costWithVat: calculateCost(e)));
      });
    });
  }

  static double calculateCost(EnergyData e, {bool withoutConsumption = false}) {
    // If the tariff is negative then assume there is no equation and no VAT applied
    if (e.tariffExVat < 0) {
      return (withoutConsumption ? 1 : e.consumption) * e.tariffExVat;
    }

    // For positive tariff values, apply the equation given by Octopus
    // min(2.30 x W + P, 33.33) 33.33 ex vat, 35 inc vat
    // P is 11.0 between 4pm and 7pm
    return (withoutConsumption ? 1 : e.consumption) *
        [
          (2.3 * e.tariffWithVat +
              (e.intervalStart.hour < 19 && e.intervalStart.hour >= 16
                  ? 11
                  : 0)),
          35.0
        ].reduce(min);
  }

  Future<CredentialParserResult> parseDevPageDoc(String webDocument) async {
//    var dom = parser.parse(webDocument);
    RegExp apiRe = new RegExp(
        r'Your API key is: <strong><code>([\S]+)<\/code><\/strong><\/p>\\n');
//    r'Your API key is: \\u003Cstrong>\\u003Ccode>([\S]+)\\u003C/code>\\u003C/strong>\\u003C/p>\\n');
    String bodyText = webDocument; //dom.nodes[0].nodes[1].nodes[0].toString();
    Match apiMatch = await apiRe.firstMatch(bodyText);
    print("API key: ${apiMatch.group(1)}");

    RegExp mpanRe = new RegExp(
        r'MPAN is: <strong><code>([\d]+)<\/code><\/strong><br>\\n');
//    r'MPAN is: \\u003Cstrong>\\u003Ccode>([\d]+)\\u003C\/code>\\u003C\/strong>\\u003Cbr>\\n');
    Match mpanMatch = await mpanRe.firstMatch(bodyText);
    print("MPAN: ${mpanMatch.group(1)}");

    RegExp msnRe = new RegExp(
        r'electricity meter\’s serial number is: <strong><code>([\S]+)<\/code><\/strong>\\n');
//    r'electricity meter\’s serial number is: \\u003Cstrong>\\u003Ccode>([\S]+)\\u003C\/code>\\u003C\/strong>\\n');

    Match msnMatch = await msnRe.firstMatch(bodyText);
    print("MSN: ${msnMatch.group(1)}");

    RegExp tariffRe = new RegExp(
        r'https:\/\/api.octopus.energy\/v1\/products\/([A-Z0-9-]+)\/electricity-tariffs\/([A-Z0-9-]+)\/standard-unit-rates\/\\\"\\n');
    Match tariffMatch = await tariffRe.firstMatch(bodyText);
    print("Tariff: ${tariffMatch.group(1)}");
    print("Tariff with Region: ${tariffMatch.group(2)}");

    return CredentialParserResult(true,
        credentials: OctopusUserCredentials(
            apiMatch.group(1),
            mpanMatch.group(1),
            msnMatch.group(1),
            tariffMatch.group(1),
            tariffMatch.group(2)));
  }
}
