import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogRequest.dart';
import 'package:table_entry/globals/speachSettingsGlobal.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';
import 'package:table_entry/speach/voiceDetection/startStopDetectionRunning.dart';

class StartStopDetection extends StatefulWidget {
  final VoidCallback startStop;
  final Function(String) changeRecordingData;
  const StartStopDetection(
      {super.key, required this.startStop, required this.changeRecordingData});

  @override
  _StartStopDetectionState createState() => _StartStopDetectionState();
}

class _StartStopDetectionState extends State<StartStopDetection>
    with SingleTickerProviderStateMixin {
  double level = 0.0;
  late AnimationController controller;
  bool isRunning = false;
  Alignment alignment = Alignment.bottomRight;
  String recordedData = "";
  String displayedRecordedData = "";
  bool levelIsZero = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
    );
    initSpeach();
  }

  void initSpeach() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: alignment,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutQuad,
      child: AnimatedContainer(
        curve: Curves.easeInOutQuad,
        duration: const Duration(milliseconds: 500),
        margin: isRunning
            ? const EdgeInsets.only(bottom: 15)
            : const EdgeInsets.only(bottom: 86),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return isRunning
                ? StartStopDetectionRunning(
                    startStop: startStopListening, run: levelIsZero)
                : TextButton(
                    onPressed: startStopListening,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: HexColor("#8332AC"),
                          borderRadius: BorderRadius.circular(16)),
                      child: Icon(
                        Icons.mic,
                        color: isRunning ? Colors.white : Colors.white70,
                        size: 40,
                      ),
                    ));
          },
        ),
      ),
    );
  }

  void startStopListening() async {
    setState(() {
      isRunning = !isRunning;
    });
    widget.startStop();

    if (!isRunning) {
      setState(() {
        alignment = Alignment.bottomRight;
      });
      List<col> newRecentCol = await RecentLogRequest()
          .request(recordedData, RecentLogHandler().getCurrentSelected);
      if (context.mounted) {
        Provider.of<UpdateRecentLog>(context, listen: false).recentLogUpdate();
      }

      return;
    }

    setState(() {
      recordedData = "";
      displayedRecordedData = "";
      widget.changeRecordingData(displayedRecordedData);
    });
    startListening();
  }

  void startListening() {
    setState(() {
      alignment = Alignment.bottomCenter;
    });
  }

  void soundLevelListener(double level) {
    SpeachSettingsRetrevial().setMinSoundLevel =
        min(SpeachSettingsRetrevial().getMinSoundLevel as double, level);
    SpeachSettingsRetrevial().setMaxSoundLevel =
        min(SpeachSettingsRetrevial().getMaxSoundLevel as double, level);
    setState(() {
      this.level = level;
    });
    if (level == 0) {
      setState(() {
        levelIsZero = true;
      });
    }
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }
}
