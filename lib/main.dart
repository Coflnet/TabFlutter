import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:table_entry/firebase_options.dart';
import 'package:table_entry/globals/auth_service.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/globals/recordingService/recordingServer.dart';
import 'package:table_entry/launchPage.dart';
import 'package:table_entry/pages/main/currentVizulization/mainPageHeader.dart';
import 'package:table_entry/pages/main/listeningMode/listeningModeMain.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopupContainer.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';
import 'package:table_entry/pages/main/recentLogSelectHolder.dart';
import 'package:table_entry/pages/main/recognizedData.dart';
import 'package:table_entry/pages/onboarding/onboarding_dialog.dart';
import 'package:table_entry/pages/reusedWidgets/background.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footer.dart';
import 'package:table_entry/pages/reusedWidgets/responsive_scaffold.dart';
import 'package:table_entry/speach/voiceDetection/startStopDetection.dart';
import 'package:flutter_translate/flutter_translate.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exception}\n${details.stack}');
    };

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: HexColor("1D1E2B"),
    ));

    // Initialize Firebase (silently — Firebase config may not be present in dev)
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await AuthService().init();
    } catch (e) {
      debugPrint('Firebase init skipped: $e');
    }

    var delegate = await LocalizationDelegate.create(
        fallbackLocale: 'en', supportedLocales: ['en', 'de']);
    runApp(LocalizedApp(delegate, const LaunchPage()));
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> with TickerProviderStateMixin {
  bool isVisible = false;
  bool isRecording = false;
  bool switchVis = false;
  String recognizedWords = "";
  late Animation<Offset> animation;
  late Animation<Offset> animation2;
  late AnimationController controller;
  late AnimationController controller2;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    animation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1))
        .animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));
    controller2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    animation2 = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));
    loadData();
  }

  void loadData() async {
    await SaveColumn().loadColumns();
    await RecentLogHandler().loadRecentLog();
    // Show onboarding dialog on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showOnboardingIfNeeded(context);
    });
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
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= kDesktopBreakpoint;
              final content = Column(
                children: [
                  const MainPageHeader(),
                  Expanded(
                    child: AnimatedOpacity(
                      curve: Curves.easeInOutQuad,
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
              );
              final listeningOverlay = Visibility(
                visible: isRecording,
                child: Column(
                  children: [
                    Expanded(
                        child: AnimatedOpacity(
                      curve: Curves.easeInOutQuad,
                      opacity: isRecording ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: SlideTransition(
                          position: animation2,
                          child: const Listeningmodemain()),
                    )),
                  ],
                ),
              );
              final micButton = StartStopDetection(
                startStop: () => handleAnimations(),
                changeRecordingData: (String newString) =>
                    setState(() => recognizedWords = newString),
              );
              final popup = Visibility(
                  visible: isVisible,
                  child: RecentLogPopupContainer(closePopup: closePopup));

              if (isWide) {
                return ResponsiveScaffold(
                  selectedIndex: 0,
                  body: Stack(
                    children: [
                      content,
                      listeningOverlay,
                    ],
                  ),
                  overlays: [micButton, popup],
                );
              }

              return Scaffold(
                body: Stack(
                  children: [
                    const Background(),
                    content,
                    listeningOverlay,
                    SlideTransition(position: animation, child: const Footer()),
                    micButton,
                    popup,
                  ],
                ),
              );
            })));
  }

  void handleAnimations() async {
    if (!isRecording) {
      setState(() {
        isRecording = true;
      });
      playAnimations(false);
      return;
    }
    playAnimations(true);

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      isRecording = !isRecording;
    });
  }

  void playAnimations(bool flip) async {
    if (flip) {
      controller.reverse();
      controller2.reverse();

      return;
    }

    controller.forward();
    await Future.delayed(const Duration(microseconds: 200));
    controller2.forward();
  }

  void closePopup() {
    setState(() {
      isVisible = !isVisible;
    });
  }
}
