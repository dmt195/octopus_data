import 'package:meta/meta.dart';

@immutable
abstract class MainState {
  final bool isLoading = false;
  final SettingsState settingsState = SettingsState.UNKNOWN;
  final DateTime dayOfInterest = DateTime.now();
}

class InitialMainState extends MainState {}

class DataRequestState extends MainState {
  final bool isLoading = true;
}

class DataAvailableState extends MainState {}

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

