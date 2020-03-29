import 'package:meta/meta.dart';

@immutable
abstract class MainEvent {}

class DownloadRequestEvent extends MainEvent {}

class SavedDataReadyEvent extends MainEvent {}

class DataAvailableEvent extends MainEvent {}


