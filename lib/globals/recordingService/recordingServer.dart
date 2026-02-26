import 'package:flutter/material.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recordingService/recordService.dart';

String reconizedWords = "";

/// Represents an entry that was created during a recording session.
class RecordedEntry {
  final col entry;
  final DateTime createdAt;

  RecordedEntry({required this.entry, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();
}

class RecordingServer extends ChangeNotifier {
  static final RecordingServer _instance = RecordingServer._internal();

  factory RecordingServer() {
    return _instance;
  }

  RecordingServer._internal();

  /// Entries created during the current recording session.
  final List<RecordedEntry> _sessionEntries = [];

  /// Number of audio segments processed in this session.
  int _processedSegments = 0;

  Future<void> startStreaming() async {
    _sessionEntries.clear();
    _processedSegments = 0;
    reconizedWords = "";
    notifyListeners();
    RecordService.instance.init();
    await RecordService.instance.start();
  }

  Future<void> stopRecorder() async {
    await RecordService.instance.stop();
  }

  void setText(String text) {
    reconizedWords = text;
    notifyListeners();
  }

  /// Called when a new entry is created from recognized speech.
  void addSessionEntry(col entry) {
    _sessionEntries.insert(0, RecordedEntry(entry: entry));
    notifyListeners();
  }

  /// Called when an audio segment is sent for processing.
  void incrementProcessedSegments() {
    _processedSegments++;
    notifyListeners();
  }

  List<RecordedEntry> get sessionEntries => _sessionEntries;
  int get processedSegments => _processedSegments;
  String get getReconizedWords => reconizedWords;
}
