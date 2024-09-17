import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/pages/main/currentVizulization/currentStateHeader.dart';
import 'package:table_entry/pages/main/currentVizulization/currentStatusVisulization.dart';
import 'package:table_entry/pages/main/currentVizulization/mainPageHeader.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';
import 'package:table_entry/pages/main/recognizedData.dart';
import 'package:table_entry/pages/main/selectedColumn/selectCollumnMain.dart';
import 'package:table_entry/pages/main/selectedColumn/selectColumnSelector.dart';
import 'package:table_entry/pages/reusedWidgets/background.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footer.dart';
import 'package:table_entry/speach/voiceDetection/startStopDetection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: HexColor("1D1E2B"),
  ));
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    SaveColumn().loadColumns();
    RecentLogHandler().loadRecentLog();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "WorkSans"),
      home: Scaffold(
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => newVoiceDataNotifer()),
            ChangeNotifierProvider(create: (_) => UpdateRecentLog())
          ],
          child: Stack(
            children: [
              const Background(),
              Column(
                children: <Widget>[
                  const MainPageHeader(),
                  const CurrentStateHeader(),
                  const SelectCollumnMain(),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: const RecentLog()),
                  )
                ],
              ),
              const Footer(),
              const StartStopDetection(),
            ],
          ),
        ),
      ),
    );
  }
}
