import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:octopus_data/access_controller.dart';
import 'package:octopus_data/home_page.dart';
import 'package:octopus_data/injection.dart';
import 'package:octopus_data/settings_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureInjection(Environment.PROD);
  SharedPreferences.getInstance().then((instance) {
    GetIt.I<KeyValueStore>().prefs = instance; // Storage service is a service to manage all shared preferences stuff. I keep the instance there and access it whenever i wanted.
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final KeyValueStore ac = GetIt.I<KeyValueStore>();
  @override
  Widget build(BuildContext context) {
    return
        MaterialApp(
          title: 'Octopus data',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(),
          routes: {'/settings': (context) => SettingsWidget()},
    );
  }
}
