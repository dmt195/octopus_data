import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc_main/bloc.dart';
import 'bloc_main/main_bloc.dart';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  String _tariffCurl;
  String _consumptionCurl;
  String _apiKey;
  String _mpanNo;
  String _serialNo;
  String _tariff;
  String _regionalTariff;

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return BlocBuilder<MainBloc, MainState>(builder: (context, state) {
      MainBloc bloc = BlocProvider.of<MainBloc>(context);
      return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "We need some information to be able to access your account and tariff information."),
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text(
                                "Electricity Consumption 'Curl' Command:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextFormField(
                              initialValue: bloc.keyValueStore.consumptionCurl,
                              minLines: 4,
                              maxLines: 4,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                RegExp re = new RegExp(
                                    r'^curl -u \"([\S]+)\:\".+ts\/([0-9]{13})\/meters\/([A-Za-z0-9]{5,20})\/consumption');
                                Match firstMatch = re.firstMatch(value);
                                if (value.isEmpty) {
                                  return "This can't be emtpy";
                                } else if (firstMatch == null) {
                                  return "This doesn't look right";
                                } else {
                                  setState(() {
                                    _consumptionCurl = value;
                                    _apiKey = firstMatch.group(1);
                                    _mpanNo = firstMatch.group(2);
                                    _serialNo = firstMatch.group(3);
                                  });
                                  bloc.keyValueStore.saveConsumptionCredentials(
                                      _apiKey, _mpanNo, _serialNo);
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Text(
                                "Tarrif 'Curl' Command:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextFormField(
                              minLines: 4,
                              maxLines: 4,
                              initialValue: bloc.keyValueStore.tariffCurl,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                RegExp re = new RegExp(
                                    r'^curl -u \"([\S]+)\:\".+products\/([\S]+)\/electricity-tariffs\/([\S]+)\/standard-unit-rates\/"');
                                Match firstMatch = re.firstMatch(value);
                                if (value.isEmpty) {
                                  return "This can't be emtpy";
                                } else if (firstMatch == null) {
                                  return "This doesn't look right";
                                } else if (firstMatch.group(1) != _apiKey) {
                                  return "Api keys don't match";
                                } else {
                                  setState(() {
                                    _tariffCurl = value;
                                    _tariff = firstMatch.group(2);
                                    _regionalTariff = firstMatch.group(3);
                                  });
                                  bloc.keyValueStore.saveTariffCredentials(
                                      _tariff, _regionalTariff);
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8.0, top: 16.0),
                              child: Text(
                                "How do I find this information?",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: FlatButton(
                                    child: Text(
                                      " < Click here to go to your 'Developer page' >",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                    onPressed: () {
                                      _launchURL(
                                          "https://octopus.energy/dashboard/developer/");
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                  "Copy and paste these two highlighted commands, one for consumption, and one for tarrif data. We will extract key information from them."),
                            ),
                            Image.asset("assets/images/dev_page.png"),
                            // Add TextFormFields and RaisedButton here.
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FlatButton(
                          child: (!bloc.state.isLoading)
                              ? Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                )
                              : SizedBox.fromSize(
                                  size: Size.fromRadius(8.0),
                                  child: CircularProgressIndicator()),
                          color: Colors.deepPurple,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              // save values
                              bloc.keyValueStore
                                  .upDateCurls(_consumptionCurl, _tariffCurl)
                                  .then((_) {
                                bloc.add(PreferencesSavedEvent());
//                                _ackAlert(context);
                                Navigator.of(context).pop();
                              });
                            }
                          },
                        ),
                        FlatButton(
                          child: (!bloc.state.isLoading)
                              ? Text(
                                  "Clear",
                                  style: TextStyle(color: Colors.white),
                                )
                              : SizedBox.fromSize(
                                  size: Size.fromRadius(8.0),
                                  child: CircularProgressIndicator()),
                          color: Colors.deepPurple,
                          onPressed: () {
                            // save values
                            bloc.add(ClearAllDataEvent());
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      setState(() {
        _consumptionCurl = Provider.of<MainBloc>(context, listen: false)
            .keyValueStore
            .consumptionCurl;
        _tariffCurl = Provider.of<MainBloc>(context, listen: false)
            .keyValueStore
            .tariffCurl;
      });
    }();
  }

  Future<void> _ackAlert(BuildContext context) {
    TextStyle style = TextStyle(fontSize: 12);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Credentials saved...'),
          content: Table(
            columnWidths: {
              0: FractionColumnWidth(0.25),
              1: FractionColumnWidth(0.75)
            },
            border: TableBorder.symmetric(
                inside: BorderSide(width: 1, style: BorderStyle.none),
                outside: BorderSide(width: 1, style: BorderStyle.none)),
            children: [
              TableRow(children: [
                Text("API Key", style: style),
                Text(_apiKey, style: style),
              ]),
              TableRow(children: [
                Text("MPAN", style: style),
                Text(_mpanNo, style: style),
              ]),
              TableRow(children: [
                Text("MSN", style: style),
                Text(_serialNo, style: style),
              ]),
              TableRow(children: [
                Text("Tariff", style: style),
                Text(_tariff, style: style),
              ]),
              TableRow(children: [
                Text("Regional", style: style),
                Text(_regionalTariff, style: style),
              ]),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
