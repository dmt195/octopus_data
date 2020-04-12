import 'package:meta/meta.dart';
import 'package:octopus_data/data/moor_database.dart';

@immutable
abstract class MainEvent {}

class DownloadRequestEvent extends MainEvent {}

class SavedDataReadyEvent extends MainEvent {}

class DataAvailableEvent extends MainEvent {
  final List<EnergyData> data;

  DataAvailableEvent(this.data);

}

class DateChosenEvent extends MainEvent {
  final DateTime date;

  DateChosenEvent(this.date);
}

class PreferencesSavedEvent extends MainEvent {
  final String curl1;
  final String curl2;

  PreferencesSavedEvent(this.curl1, this.curl2);
}

class ClearAllDataEvent extends MainEvent {}
