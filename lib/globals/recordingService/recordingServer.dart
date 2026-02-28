import 'package:flutter/material.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogRequest.dart';
import 'package:table_entry/globals/recordingService/recordService.dart';

String reconizedWords = "";

/// Represents an entry that was created during a recording session.
class RecordedEntry {
  final col entry;
  final DateTime createdAt;

  /// Audio IDs that were combined to produce this entry.
  final List<String> audioIds;

  /// The initial transcription text from the recognition.
  final String? initialTranscription;

  /// The initial column values before any user edits.
  final Map<String, String> initialColumns;

  RecordedEntry(
      {required this.entry,
      DateTime? createdAt,
      this.audioIds = const [],
      this.initialTranscription,
      Map<String, String>? initialColumns})
      : createdAt = createdAt ?? DateTime.now(),
        initialColumns = initialColumns ?? {};
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

  /// Last error message from the recording service (e.g. no microphone found).
  String? _lastError;

  Future<void> startStreaming() async {
    _sessionEntries.clear();
    _processedSegments = 0;
    _lastError = null;
    reconizedWords = "";
    notifyListeners();
    // Reset the API session so previous recording text doesn't leak
    RecentLogRequest.resetSession();
    RecordService.instance.init();

    // Listen for async errors from the native background isolate
    RecordService.instance.onError = (String error) {
      _lastError = error;
      notifyListeners();
    };

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
  void addSessionEntry(col entry,
      {List<String> audioIds = const [],
      String? initialTranscription,
      Map<String, String>? initialColumns}) {
    _sessionEntries.insert(
        0,
        RecordedEntry(
          entry: entry,
          audioIds: audioIds,
          initialTranscription: initialTranscription,
          initialColumns: initialColumns,
        ));
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

  /// Returns and clears the last error message, if any.
  String? consumeError() {
    final err = _lastError;
    _lastError = null;
    return err;
  }

  String? get lastError => _lastError;
}
