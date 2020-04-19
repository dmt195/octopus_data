import 'package:meta/meta.dart';
import 'package:octopus_data/bloc_main/bloc.dart';
import 'package:octopus_data/data/moor_database.dart';

@immutable
abstract class MainState {
  final bool isLoading = false;
  final SettingsStatus settingsState = SettingsStatus.UNKNOWN;
  final DateTime dayOfInterest = DateTime.now();
  final List<EnergyData> data = [];
  final OctopusUserCredentials credentials =
      OctopusUserCredentials("", "", "", "", "");
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

class DevPageForegroundedState extends MainState {}

class ShowCredentialsState extends MainState {
  final OctopusUserCredentials credentials;

  ShowCredentialsState(this.credentials);
}

enum SettingsStatus { UNKNOWN, VALID, INVALID }
