import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:octopus_data/access_controller.dart';
import 'package:octopus_data/data/moor_database.dart';
import 'package:octopus_data/repo/agile_repo.dart';
import 'package:octopus_data/repo/repo_controller.dart';
import './bloc.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  @override
  MainState get initialState {
    return InitialMainState();
  }

  KeyValueStore keyValueStore;
  RepositoryController repositoryController;
  AppDatabase db;

  MainBloc(this.db) {
    init();
  }

  init() async {
    keyValueStore = await KeyValueStore();
    await keyValueStore.init();
    add(SavedDataReadyEvent());
  }


  @override
  Stream<MainState> mapEventToState(MainEvent event,) async* {
    print("In mapEventToState with $event");
    if (event is DownloadRequestEvent) {
      print("DownloadRequestEvent fired!");
      yield DataRequestState();
      await repositoryController.getAndSaveAllTariffData();
      await repositoryController.getAndSaveAllConsumptionData();
      await repositoryController.findCompletableChargeMatchesAndAddToDb();
      yield DataAvailableState();
    } else if (event is SavedDataReadyEvent) {
      print("SavedDataReadyEvent fired!");
      // if empty then fire the settings page event
      if (keyValueStore.apiKey.isEmpty) {
        print("api key is empty");
        yield SettingsRequiredState();
      } else {
        print("api key is present");
        // ready the repos with their appropriate settings
        repositoryController = RepositoryController(db, keyValueStore, AgileRepository(keyValueStore));
        yield DataAvailableState();
      }
    }
  }
}
