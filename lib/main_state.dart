import 'package:meta/meta.dart';
import 'package:octopus_data/data/moor_database.dart';

@immutable
abstract class MainState {
  final bool isLoading = false;
  final SettingsState settingsState = SettingsState.UNKNOWN;
  final DateTime dayOfInterest = DateTime.now();
  final List<EnergyData> dataReady = [];
}

class InitialMainState extends MainState {
  final bool isLoading = false;
  final SettingsState settingsState = SettingsState.UNKNOWN;
  final DateTime dayOfInterest = DateTime.now();
}

class DataRequestState extends MainState {
  final bool isLoading = true;
}

class DataAvailableState extends MainState {
  final bool isLoading = false;
  final List<EnergyData> dataReady;

  DataAvailableState(this.dataReady);
}

class SavedDataAvailableState extends MainState {}

class SettingsRequiredState extends MainState {
  final SettingsState settingsState = SettingsState.INVALID;
}

class SettingsCompletedState extends MainState {
  final SettingsState settingsState = SettingsState.VALID;
}



enum SettingsState {
  UNKNOWN, VALID, INVALID
}

