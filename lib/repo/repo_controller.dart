import 'dart:math';

import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/repo/agile_repo.dart';

class RepositoryController {
  AppDatabase db;

  RepositoryController(this.db);

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
        print("Making tariff API call (page = $page)");
        var response = await getRatesForDateRange(
            lastTariffEntry ?? tomorrow.subtract(Duration(days: 30)), tomorrow,
            page: page);
        if (response != null && response.count > 0) {
          print("Inserting ${response.count} items into Tariffs Table");
          response.results.forEach((result) {
            db.insertTariffData(result.toDbItem());
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
        print("Making consumption API call (page = $page)");
        var response = await getConsumptionForDateRange(
            lastConsumptionEntry ?? today.subtract(Duration(days: 30)), today,
            page: page);
        if (response != null && response.count > 0) {
          print("Inserting ${response.count} items into Consumption Table");
          response.results.forEach((result) {
            db.updateWithConsumptionData(result.toDbItem());
          });
        }
        isMoreResults = response != null && response.next != null;
        page++;
      }
    }
  }

  Future<void> findCompletableChargeMatchesAndAddToDb({bool recalculate = false}) async {
    //find all data where tariff and consumption values exist but where no cost data exists
    List<EnergyData> dbResponseData = await db.getUncostedEntries();
    List<EnergyData> dataToUpdate;
    if (dbResponseData == null || dbResponseData.isEmpty) {
      print("Nothing to update cost wise");
      return null;
    }

    if (!recalculate) {
      dataToUpdate = dbResponseData.where((e) => e.costWithVat == null)
          .toList();
    } else {
      dataToUpdate = dbResponseData;
    }
    print("Updating costs... (for ${dataToUpdate.length} items)");
    dataToUpdate.forEach((e) {
        db.updateWithCostData(EnergyData(
            intervalStart: e.intervalStart,
            costWithVat: calculateCost(
                e.tariffWithVat, e.consumption, e.intervalStart.hour)));
    });
  }

  //should take an EnergyData instead
  static double calculateCost(double perKwHr, double consumption, int hour) {
    //min(2.30 x W + P, 33.33) 33.33 ex vat, 35 inc vat
    //P is 11.0 between 4pm and 7pm
    return consumption * [(2.3 * perKwHr + (hour < 19 && hour >= 16 ? 11 : 0)), 35.0].reduce(min);
  }
}
