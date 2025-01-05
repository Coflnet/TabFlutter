import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/globals/recordingService/recordingServer.dart';
import 'package:table_entry/main.dart';

class LaunchPageLogo extends StatefulWidget {
  const LaunchPageLogo({Key? key}) : super(key: key);

  @override
  _LaunchPageLogoState createState() => _LaunchPageLogoState();
}

class _LaunchPageLogoState extends State<LaunchPageLogo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadApp();
    });
  }

  void loadApp() async {
    SaveColumn().loadColumns();
    RecentLogHandler().loadRecentLog();
    final RecordingServer newRec = RecordingServer();
    SaveColumn().setRecordingServerREF = newRec;

    Locale local = Localizations.localeOf(context);
    changeLocale(context, SaveColumn().getlanguage);

    RecordingServer().startRecorder();
    if (local.languageCode == "de") {
      changeLocale(context, "de");
      SaveColumn().setlanguage = "de";
      SaveColumn().saveFile();
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const Main(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
        transitionDuration: const Duration(milliseconds: 0),
      ),
    );
    initOpus(await opus_flutter.load());
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Loading...",
        style: TextStyle(
            color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
      ),
    );
  }
}
