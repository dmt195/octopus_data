import 'package:flutter/material.dart';
import 'package:octopus_data/bloc.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/home_page.dart';
import 'package:octopus_data/settings_widget.dart';
import 'package:provider/provider.dart';

void main() => runApp(Provider<AppDatabase>(
    create: (_) => AppDatabase(),
    dispose: (_, db) => db.close(),
    child: MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return
        Provider<MainBloc>(
          create: (_) => MainBloc(Provider.of<AppDatabase>(context, listen: false)),
          child: MaterialApp(
            title: 'Octopus data',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: MyHomePage(),
            routes: {'/settings': (context) => SettingsWidget()},
    ),
        );
  }
}
