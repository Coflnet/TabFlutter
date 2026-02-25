import 'package:flutter/material.dart';
import 'package:table_entry/globals/recordingService/recordService.dart';
import 'package:record/record.dart';

String reconizedWords = "";
final record = AudioRecorder();

class RecordingServer extends ChangeNotifier {
  static final RecordingServer _instance = RecordingServer._internal();

  factory RecordingServer() {
    return _instance;
  }

  RecordingServer._internal();

  void startStreaming() async {
    RecordService.instance.init();
    await RecordService.instance.start();
  }

  void stopRecorder() async {
    await RecordService.instance.stop();
    await record.stop();
    // TODO: dispose
  }

  void setText(String text) {
    reconizedWords = text;
    notifyListeners();
  }

  String get getReconizedWords => reconizedWords;
}
