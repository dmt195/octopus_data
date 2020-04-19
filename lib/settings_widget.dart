import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'bloc_main/bloc.dart';
import 'bloc_main/main_bloc.dart';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    final Completer<WebViewController> webviewController =
        Completer<WebViewController>();

    return BlocBuilder<MainBloc, MainState>(builder: (context, state) {
      MainBloc bloc = BlocProvider.of<MainBloc>(context);

      return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: WebView(
                  initialUrl: "https://octopus.energy/dashboard/developer/",
                  onWebViewCreated: (WebViewController ctrl) =>
                      webviewController.complete(ctrl),
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageFinished: (url) => bloc.add(WebNavEvent(url)),
                ),
              ),
              FutureBuilder<WebViewController>(
                future: webviewController.future,
                builder: (BuildContext context,
                    AsyncSnapshot<WebViewController> snapshot) {
                  final WebViewController controller = snapshot.data;
                  if (bloc.state is DevPageForegroundedState) {
                    return MaterialButton(
                      color: Colors.red,
                      child: Text(
                        'Get Credentials',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        String body = await controller.evaluateJavascript(
                            'document.documentElement.innerHTML');
                        bloc.add(DocumentProcessRequestEvent(body));
                      },
                    );
                  } else if (bloc.state is ShowCredentialsState) {
                    _ackAlert(context, bloc.state.credentials);
                    return Container();
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  // An alert dialog for confirming what's been saved
  Future<void> _ackAlert(
      BuildContext context, OctopusUserCredentials credentials) {
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
                Text(credentials.apiKey, style: style),
              ]),
              TableRow(children: [
                Text("MPAN", style: style),
                Text(credentials.mpan, style: style),
              ]),
              TableRow(children: [
                Text("MSN", style: style),
                Text(credentials.msn, style: style),
              ]),
              TableRow(children: [
                Text("Tariff", style: style),
                Text(credentials.tariff, style: style),
              ]),
              TableRow(children: [
                Text("Regional", style: style),
                Text(credentials.regionalTariff, style: style),
              ]),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                //Keep popping until you're home! (2 pops down - one for the dialog, on for settings
                Navigator.of(context)
                    .popUntil((route) => !Navigator.of(context).canPop());
              },
            ),
          ],
        );
      },
    );
  }
}
