import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:octopus_data/access_controller.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/data_list_item.dart';
import 'package:octopus_data/graph_widget.dart';
import 'package:octopus_data/repo/repo_controller.dart';
import 'package:octopus_data/summariser_widget.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  final String title = 'Octopus Rates and Usage';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  DateTime _dayOfInterest = DateTime.now();
  final RepositoryController rc = GetIt.I<RepositoryController>();
  final KeyValueStore ac = GetIt.I<KeyValueStore>();
  final AppDatabase db = GetIt.I<AppDatabase>();

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    await rc.getAndSaveAllTariffData();
    await rc.getAndSaveAllConsumptionData();
    await rc.findCompletableChargeMatchesAndAddToDb(recalculate: false);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      if (ac.apiKey == null || ac.apiKey.isEmpty) {
        Navigator.of(context).pushNamed('/settings');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[SettingsMenuIcon()],
      ),
      body: StreamBuilder<List<EnergyData>>(
        stream: db.watchAllEnergyData(_dayOfInterest),
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
        child: isLoading
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

class SettingsMenuIcon extends StatelessWidget {
  const SettingsMenuIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.settings,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
//          showToast(context, "Coming soon...");
        });
  }
}

void showToast(BuildContext context, String text) {
  final scaffold = Scaffold.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(text),
      action:
          SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}
