import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/material.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/graph_widget.dart';
import 'package:octopus_data/repo/repo_controller.dart';
import 'package:provider/provider.dart';
import 'extension_functions.dart';

void main() => runApp(Provider<AppDatabase>(
    create: (_) => AppDatabase(),
    dispose: (_, db) => db.close(),
    child: MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<RepositoryController>(
      create: (_) => RepositoryController(Provider.of<AppDatabase>(context)),
      child: MaterialApp(
        title: 'Octopus data',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Octopus Rates and Usage'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _dayOfInterest = DateTime.now();
  bool isActive = false;

  Future<void> _fetchData() async {
    setState(() {
      isActive = true;
    });
    await Provider.of<RepositoryController>(context).getAndSaveAllTariffData();
    await Provider.of<RepositoryController>(context)
        .getAndSaveAllConsumptionData();
    await Provider.of<RepositoryController>(context)
        .findCompletableChargeMatchesAndAddToDb(recalculate: false);
    setState(() {
      isActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<List<EnergyData>>(
        stream:
            Provider.of<AppDatabase>(context).watchAllEnergyData(_dayOfInterest),
        initialData: [],
        builder: ((context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return Container(
              child: Center(child: Text("No Data For This Date (Yet)")),
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CalendarStrip(
                startDate: DateTime.now().subtract(Duration(days: 30)),
                endDate: DateTime.now().add(Duration(days: 2)),
                onDateSelected: (date) => _setDateOfInterest(date),
                selectedDate: _dayOfInterest,
              ),
              SummariserWidget(snapshot.data),
              GraphWidget(snapshot.data),
              DataListViewWidget(snapshot.data),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        tooltip: 'Fetch Data',
        child: isActive
            ? CircularProgressIndicator(
                backgroundColor: Colors.white,
              )
            : Icon(Icons.cloud_download),
      ),
    );
  }

  _setDateOfInterest(date) {
    setState(() {
      _dayOfInterest = date;
    });
  }
}

class DataListViewWidget extends StatelessWidget {
  final List<EnergyData> _data;

  DataListViewWidget(
    this._data, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _data.isEmpty
          ? Center(child: Text("No Data For This Date (Yet)"))
          : ListView.separated(
              itemCount: _data.length,
              reverse: true,
              itemBuilder: (context, index) {
                EnergyData item = _data[index];
                double actualTariff = RepositoryController.calculateCost(
                    item.tariffWithVat, 1, item.intervalStart.hour);

                return ListTile(
                  leading: Text(
                      "${item.intervalStart.asTimeString()} - ${item.intervalStart.add(Duration(minutes: 30)).asTimeString()}"),
                  title: Text(item.costWithVat != null
                      ? "Est Cost: ${item.costWithVat?.toStringAsFixed(2)}p"
                      : "Pending"),
                  subtitle: Text(
                      "Tariff: ${item.tariffWithVat?.toStringAsFixed(2)} p/kWh (Wholesale),\n"
                      "Tariff: ${actualTariff.toStringAsFixed(2)} p/kWh (Actual)\n"
                      "Consumption: ${item.consumption?.toStringAsFixed(2) ?? "-"} kWh"),
                  trailing: Container(
                    height: 40.0,
                    width: 10.0,
                    color: _getTariffBasedColour(actualTariff),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            ),
    );
  }
}

Color _getTariffBasedColour(double actualTariff) {
  //Super Green for < 5
  //Green for < 10p actual
  //Yellow for 10-20p
  //Amber2 for 20-30p
  //Red for > 30p
  if (actualTariff < 5.0) {
    return Colors.greenAccent;
  } else if (actualTariff <= 10.0) {
    return Colors.yellow;
  } else if (actualTariff <= 20.0) {
    return Colors.amber;
  } else if (actualTariff <= 30.0) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

class SummariserWidget extends StatelessWidget {
  final List<EnergyData> data;

  SummariserWidget(this.data);

  @override
  Widget build(BuildContext context) {
    if (data == null || data.isEmpty) {
      return Container();
    }
    double totalCost = data.map((e) => e.costWithVat).toList().sum();
    double totalConsumption = data.map((e) => e.consumption).toList().sum();
    return Container(
      color: Colors.grey.withOpacity(0.5),
//      height: 40,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "Day's Cost",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("£${(totalCost / 100 + 0.21).toStringAsFixed(2)}")
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                  "Day's Usage",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${totalConsumption.toStringAsFixed(2)} kWh")
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                  "Effective Rate",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                totalConsumption != 0 ?
                Text(
                    "${(totalCost / totalConsumption).toStringAsFixed(2)} p/kWh") :
                    Text("-")
              ],
            )
          ],
        ),
      ),
    );
  }
}
