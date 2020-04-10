import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';

part 'moor_database.g.dart';

class Energy extends Table {
  DateTimeColumn get intervalStart => dateTime().nullable()();

  DateTimeColumn get intervalEnd => dateTime().nullable()();

  RealColumn get tariffWithVat => real().nullable()();

  RealColumn get tariffExVat => real().nullable()();

  RealColumn get consumption => real().nullable()();

  RealColumn get costWithVat => real().nullable()();

  @override
  Set<Column> get primaryKey => {intervalStart};
}

@singleton
@UseMoor(tables: [Energy])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite', logStatements: false));

  int get schemaVersion => 1;

  Stream<List<EnergyData>> watchAllEnergyData(DateTime dayStartRange) {
    DateTime startOfDay = dayStartRange
        .subtract(Duration(hours: dayStartRange.hour))
        .subtract(Duration(minutes: dayStartRange.minute))
        .subtract(Duration(seconds: dayStartRange.second));

    return (select(energy)
          ..where((e) =>
              e.intervalStart.isBiggerOrEqualValue(startOfDay) &
              e.intervalStart.isSmallerOrEqualValue(startOfDay
                  .add(Duration(hours: 23))
                  .add(Duration(minutes: 59))))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.intervalStart, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future insertTariffData(Insertable<EnergyData> tariff) =>
      into(energy).insert(tariff);

  Future<DateTime> getLatestTariff() async {
    EnergyData dataPoint = await (select(energy)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.intervalEnd, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingle();
    return dataPoint?.intervalStart?.add(Duration(minutes: 30));
  }

  Future<DateTime> getDateOfLatestConsumptionData() async {
    EnergyData dataPoint = await (select(energy)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.intervalEnd, mode: OrderingMode.desc)
          ])
          ..where((e) => e.consumption.isBiggerThanValue(0.0))
          ..limit(1))
        .getSingle();
//    print(
//        "Last Consumption datapoint found at ${dataPoint?.intervalStart?.toIso8601String()}.");
    return dataPoint?.intervalStart;
  }

  Future<void> updateWithConsumptionData(EnergyData dbItem) async {
    return await (update(energy)
          ..where((e) => e.intervalStart.equals(dbItem.intervalStart)))
        .write(EnergyCompanion(consumption: Value(dbItem.consumption)));
  }

  Future<void> updateWithCostData(EnergyData dbItem) async {
    return await (update(energy)
          ..where((e) => e.intervalStart.equals(dbItem.intervalStart)))
        .write(EnergyCompanion(costWithVat: Value(dbItem.costWithVat)));
  }

  Future<List<EnergyData>> getUncostedEntries() async {
    List<EnergyData> data = await (select(energy)
          ..where((e) => e.consumption.isBiggerThanValue(0.0)))
        .get();
//    print("Found ${data.length} uncosted entries");
    return data;
  }

  Future<void> clearData() async {
    //todo
    return;
  }


}
