import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/globals/recordingService/recordingServer.dart';
import 'package:table_entry/globals/recordingService/opus_init_stub.dart'
    if (dart.library.io) 'package:table_entry/globals/recordingService/opus_init_native.dart';
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
    try {
      await SaveColumn().loadColumns();
      await RecentLogHandler().loadRecentLog();
      final RecordingServer newRec = RecordingServer();
      SaveColumn().setRecordingServerREF = newRec;

      // Use device locale (not app locale) to detect language on first launch
      final deviceLocale =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final savedLang = SaveColumn().getlanguage;

      if (savedLang == "en" && deviceLocale == "de") {
        // First launch on a German device — switch to German
        changeLocale(context, "de");
        SaveColumn().setlanguage = "de";
        SaveColumn().saveFile();
      } else {
        changeLocale(context, savedLang);
      }
      if (!mounted) return;
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
      await initOpusIfAvailable();
    } catch (e, stack) {
      debugPrint('loadApp failed: $e\n$stack');
      // Navigate to Main anyway so the user doesn't see a black screen
      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Main(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) => child,
            transitionDuration: const Duration(milliseconds: 0),
          ),
        );
      }
    }
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
