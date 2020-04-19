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
  final OctopusUserCredentials credentials;

  PreferencesSavedEvent(this.credentials);
}

class ClearAllDataEvent extends MainEvent {}

class DocumentProcessRequestEvent extends MainEvent {
  final String webDocumentAsString;
  DocumentProcessRequestEvent(this.webDocumentAsString);
}


class OctopusUserCredentials {
  String apiKey;
  String mpan;
  String msn;
  String tariff;
  String regionalTariff;

  OctopusUserCredentials(this.apiKey, this.mpan, this.msn, this.tariff,
      this.regionalTariff);
}

class CredentialParserResult {
  OctopusUserCredentials credentials;
  bool success;

  CredentialParserResult(this.success, {this.credentials});

}

class WebNavEvent extends MainEvent {
  String url;

  WebNavEvent(this.url);


}
