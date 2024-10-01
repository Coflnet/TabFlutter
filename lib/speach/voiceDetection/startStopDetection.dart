import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  SpeechToText speech = SpeechToText();
  double level = 0.0;
  late AnimationController controller;
  bool isRunning = false;
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
    setState(() {
      speech.initialize(onStatus: statusListener);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: isRunning
          ? const EdgeInsets.only(bottom: 15)
          : const EdgeInsets.only(bottom: 86),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          double scale = 1 + (level / 50);
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
    );
  }

  void startStopListening() async {
    setState(() {
      isRunning = !isRunning;
    });
    widget.startStop();

    if (!isRunning) {
      speech.stop();
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
    speech.statusListener = statusListener;

    var options = SpeechListenOptions(
        onDevice: SpeachSettingsRetrevial().get_onDevice,
        listenMode: ListenMode.deviceDefault,
        cancelOnError: true,
        partialResults: false,
        autoPunctuation: true,
        enableHapticFeedback: true);
    speech.listen(
      onResult: onResult,
      listenFor: const Duration(seconds: 3000),
      pauseFor: const Duration(seconds: 40),
      localeId: SpeachSettingsRetrevial().getCurrentLocaleId,
      onSoundLevelChange: soundLevelListener,
      listenOptions: options,
    );
    setState(() {});
  }

  void onResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      setState(() {
        recordedData = "$recordedData ${result.recognizedWords}";
        displayedRecordedData =
            "$displayedRecordedData\n${result.recognizedWords}.";
      });
      widget.changeRecordingData(displayedRecordedData);
    }
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
    if (!speech.isListening && status == 'done') {
      speech.stop();
      Future.delayed(const Duration(milliseconds: 20), () {
        if (isRunning) {
          startListening();
        }
      });
    }
    setState(() {
      lastStatus = status;
    });
  }
}
