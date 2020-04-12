import 'package:meta/meta.dart';
import 'package:octopus_data/data/moor_database.dart';

@immutable
abstract class MainState {
  final bool isLoading = false;
  final SettingsStatus settingsState = SettingsStatus.UNKNOWN;
  final DateTime dayOfInterest = DateTime.now();
  final List<EnergyData> data = [];
}

class InitialMainState extends MainState {
  final bool isLoading = false;
  final SettingsStatus settingsState = SettingsStatus.UNKNOWN;
  final DateTime dayOfInterest = DateTime.now();
}

class DataRequestState extends MainState {
  final bool isLoading = true;
}

class CompletedFetchState extends MainState {
  final bool isLoading = false;
}

class DataAvailableState extends MainState {
  final List<EnergyData> data;

  DataAvailableState(this.data);
}

class SavedDataAvailableState extends MainState {}

class SettingsRequiredState extends MainState {
  final SettingsStatus settingsState = SettingsStatus.INVALID;
}

class SettingsCompletedState extends MainState {
  final SettingsStatus settingsState = SettingsStatus.VALID;
}



enum SettingsStatus {
  UNKNOWN, VALID, INVALID
}

