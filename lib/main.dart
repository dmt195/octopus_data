import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus_data/bloc_main/bloc.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/home_page.dart';
import 'package:octopus_data/settings_widget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(Provider<AppDatabase>(
    create: (_) => AppDatabase(),
    dispose: (_, db) => db.close(),
    child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return
        BlocProvider(
          create: (_) => MainBloc(Provider.of<AppDatabase>(context)),
          child: MaterialApp(
            title: 'Octopus data',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData.dark(),
            home: MyHomePage(),
            routes: {'/settings': (context) => SettingsWidget()},
    ),
        );
  }
}
