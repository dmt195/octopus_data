import 'package:meta/meta.dart';

@immutable
abstract class MainEvent {}

class DownloadRequestEvent extends MainEvent {}

class SavedDataReadyEvent extends MainEvent {}

class DataAvailableEvent extends MainEvent {}

class DateChosenEvent extends MainEvent {
  final DateTime date;
  DateChosenEvent(this.date);
}


