import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus_data/bloc_main/bloc.dart';
import 'package:octopus_data/data_list_item.dart';
import 'package:octopus_data/graph_widget.dart';
import 'package:octopus_data/summariser_widget.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: ((BuildContext context, MainState mainState) {
        MainBloc bloc = BlocProvider.of<MainBloc>(context);
        if (mainState is SettingsRequiredState) {
          //delaying the navigation allows something to be rendered before navigation
          //otherwise exceptions are thrown
          Future.delayed(Duration(milliseconds: 100))
              .then((value) => Navigator.pushNamed(context, '/settings'));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Octopus Rates and Usage'),
            actions: <Widget>[SettingsMenuIcon()],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CalendarStrip(
                startDate: DateTime.now().subtract(Duration(days: 30)),
                endDate: DateTime.now().add(Duration(days: 2)),
                onDateSelected: (date) => _setDateOfInterest(bloc, date),
                selectedDate: bloc.dayOfInterest,
              ),
              SummariserWidget(bloc.state.data),
              GraphWidget(bloc.state.data),
              bloc.state.data == null || bloc.state.data.isEmpty
                  ? Expanded(
                      child: Container(
                        child:
                            Center(child: Text("No Data For This Date (Yet)")),
                      ),
                    )
                  : DataListViewWidget(bloc.state.data),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (bloc.keyValueStore != null &&
                    bloc.keyValueStore.apiKey.isNotEmpty)
                ? () => bloc.add(DownloadRequestEvent())
                : null,
            tooltip: 'Fetch Data',
            child: mainState.isLoading
                ? CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                : Icon(Icons.cloud_download),
          ),
        );
      }),
    );
  }

  _setDateOfInterest(bloc, date) {
    bloc.add(DateChosenEvent(date));
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
