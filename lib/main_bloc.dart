import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:octopus_data/key_value_store.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/repo/agile_repo.dart';
import './bloc.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  @override
  MainState get initialState {
    return InitialMainState();
  }

  KeyValueStore keyValueStore;
  AgileRepository ar;
  AppDatabase db;
  DateTime dayOfInterest;
  List<EnergyData> dataReady;
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
//      print("Cancelling old DB sub");
    }
    var dbSub = db.watchAllEnergyData(dayOfInterest);
//    print("Subscribing to DB changes for new date ${dayOfInterest.toIso8601String()}");
    subSub = dbSub.listen((List<EnergyData> data) {
//      print("DB changed with ${data.length} entries");
      dataReady = data;
      add(DataAvailableEvent());
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
//    print("In mapEventToState with $event");
    if (event is DownloadRequestEvent) {
//      print("DownloadRequestEvent fired!");
      await getAndSaveAllTariffData();
      await getAndSaveAllConsumptionData();
      await findCompletableChargeMatchesAndAddToDb();
    } else if (event is SavedDataReadyEvent) {
//      print("SavedDataReadyEvent fired!");
      // if empty then fire the settings page event
      if (keyValueStore.apiKey.isEmpty) {
//        print("api key is empty");
        yield SettingsRequiredState();
      } else {
//        print("api key is present - getting AgileRepo instance");
        // ready the repos with their appropriate settings
        ar = AgileRepository(keyValueStore);
        add(DownloadRequestEvent());
      }
    } else if (event is DataAvailableEvent) {
      yield DataAvailableState(dataReady);
    } else if (event is DateChosenEvent) {
      dayOfInterest = event.date;
      getDataAndListen();
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
//        print("Making consumption API call (page = $page)");
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
//      print("Nothing to update cost wise");
      return null;
    }

    if (!recalculate) {
      dataToUpdate =
          dbResponseData.where((e) => e.costWithVat == null).toList();
    } else {
      dataToUpdate = dbResponseData;
    }
//    print("Updating costs... (for ${dataToUpdate.length} items)");
    db.transaction(() async {
      dataToUpdate.forEach((e) async {
        await db.updateWithCostData(EnergyData(
            intervalStart: e.intervalStart,
            costWithVat: calculateCost(
                e.tariffWithVat, e.consumption, e.intervalStart.hour)));
      });
    });
  }

  //todo should take an EnergyData instead
  static double calculateCost(double perKwHr, double consumption, int hour) {
    //min(2.30 x W + P, 33.33) 33.33 ex vat, 35 inc vat
    //P is 11.0 between 4pm and 7pm
    return consumption *
        [(2.3 * perKwHr + (hour < 19 && hour >= 16 ? 11 : 0)), 35.0]
            .reduce(min);
  }

  void clearAll() {
//    db.clearAllData();
  }
}
