import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:octopus_data/injection.iconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectableInit
void configureInjection(String environment) {
  $initGetIt(GetIt.I, environment: Environment.PROD);
}

class Environment {
  static const String DEV = "dev";
  static const String PROD = "prod";
}
