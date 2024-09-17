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

class StartStopDetection extends StatefulWidget {
  const StartStopDetection({Key? key}) : super(key: key);

  @override
  _StartStopDetectionState createState() => _StartStopDetectionState();
}

class _StartStopDetectionState extends State<StartStopDetection> {
  SpeechToText speech = SpeechToText();
  double level = 0.0;
  bool isRunning = false;
  String recordedData = "";

  @override
  void initState() {
    super.initState();
    initSpeach();
  }

  void initSpeach() {
    speech.initialize(onStatus: statusListener);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 13, 85),
        child: TextButton(
            onPressed: startStopListening,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: HexColor("#8332AC"),
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(
                Icons.mic,
                color: Colors.white70,
                size: 40,
              ),
            )),
      ),
    );
  }

  void startStopListening() async {
    print("i");
    setState(() {
      isRunning = !isRunning;
    });
    if (!isRunning) {
      speech.stop();
      List<col> newRecentCol = await RecentLogRequest()
          .request(recordedData, RecentLogHandler().getCurrentSelected);
      if (context.mounted) {
        Provider.of<UpdateRecentLog>(context, listen: false).recentLogUpdate();
      }

      return;
    }
    startListening();
  }

  void startListening() {
    var options = SpeechListenOptions(
        onDevice: SpeachSettingsRetrevial().get_onDevice,
        listenMode: ListenMode.dictation,
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
      });
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
