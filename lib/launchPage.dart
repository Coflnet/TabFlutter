import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:spables/globals/columns/saveColumn.dart';
import 'package:spables/globals/recentLogRequest/recentLogHandler.dart';
import 'package:spables/main.dart';
import 'package:spables/pages/launchPageLogo.dart';
import 'package:spables/pages/reusedWidgets/background.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({Key? key}) : super(key: key);

  @override
  _LaunchPageState createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        localizationDelegate
      ],
      supportedLocales: localizationDelegate.supportedLocales,
      locale: localizationDelegate.currentLocale,
      home: const Scaffold(
        body: Stack(
          children: <Widget>[Background(), LaunchPageLogo()],
        ),
      ),
    );
  }
}
