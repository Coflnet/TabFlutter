import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:table_entry/globals/speachSettingsGlobal.dart';

class StartStopDetection extends StatefulWidget {
  const StartStopDetection({Key? key}) : super(key: key);

  @override
  _StartStopDetectionState createState() => _StartStopDetectionState();
}

class _StartStopDetectionState extends State<StartStopDetection> {
  final SpeechToText speech = SpeechToText();
  double level = 0.0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 70),
        child: TextButton(
            onPressed: () {},
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(80)),
              child: const Icon(
                Icons.mic,
                color: Colors.grey,
                size: 50,
              ),
            )),
      ),
    );
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
      pauseFor: const Duration(seconds: 10),
      localeId: SpeachSettingsRetrevial().getCurrentLocaleId,
      onSoundLevelChange: soundLevelListener,
      listenOptions: options,
    );
  }

  void onResult(SpeechRecognitionResult result) {}
  void soundLevelListener(double level) {
    SpeachSettingsRetrevial().setMinSoundLevel =
        min(SpeachSettingsRetrevial().getMinSoundLevel as double, level);
    SpeachSettingsRetrevial().setMaxSoundLevel =
        min(SpeachSettingsRetrevial().getMaxSoundLevel as double, level);
    setState(() {
      this.level = level;
    });
  }
}
