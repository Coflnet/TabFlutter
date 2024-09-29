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
import 'package:table_entry/launchPage.dart';
import 'package:table_entry/pages/main/currentVizulization/currentStateHeader.dart';
import 'package:table_entry/pages/main/currentVizulization/currentStatusVisulization.dart';
import 'package:table_entry/pages/main/currentVizulization/mainPageHeader.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopup.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopupContainer.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';
import 'package:table_entry/pages/main/recentLogSelectHolder.dart';
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
  runApp(const LaunchPage());
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> with TickerProviderStateMixin {
  bool isVisible = false;
  bool isRecording = false;
  bool switchVis = false;
  late Animation<Offset> animation;
  late Animation<Offset> animation2;
  late AnimationController controller;
  late AnimationController controller2;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    animation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInQuad));
    controller2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation2 = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInQuad));
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
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => newVoiceDataNotifer()),
          ChangeNotifierProvider(create: (_) => UpdateRecentLog())
        ],
        child: Scaffold(
          body: Stack(
            children: [
              const Background(),
              Column(
                children: [
                  const MainPageHeader(),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: isRecording ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 700),
                      child: SlideTransition(
                        position: animation,
                        child: Column(
                          children: <Widget>[
                            RecentLogSelectHolder(closePopup: closePopup),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: isRecording,
                child: Column(
                  children: [
                    Expanded(
                        child: AnimatedOpacity(
                      opacity: isRecording ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: SlideTransition(
                        position: animation2,
                        child: Container(
                          color: Colors.white,
                          width: 300,
                          height: 400,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              SlideTransition(position: animation, child: const Footer()),
              Visibility(
                  visible: isVisible,
                  child: RecentLogPopupContainer(closePopup: closePopup))
            ],
          ),
          floatingActionButton: StartStopDetection(
            startStop: () => setState(() {
              isRecording = !isRecording;
              isRecording ? controller.forward() : controller.reverse();
              isRecording ? controller2.forward() : controller2.reverse();
            }),
            changeRecordingData: (s) {},
          ),
          floatingActionButtonLocation: isRecording
              ? FloatingActionButtonLocation.centerDocked
              : FloatingActionButtonLocation.endDocked,
        ),
      ),
    );
  }

  void handleAnimations() {}

  void closePopup() {
    setState(() {
      isVisible = !isVisible;
    });
  }
}
