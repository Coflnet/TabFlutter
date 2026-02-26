import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogRequest.dart';
import 'package:table_entry/src/vad/audio_utils.dart';
import 'package:table_entry/src/vad/core/vad_handler.dart';

import '../recentLogRequest/recentLogHandler.dart';
import '../recordingService/recordingServer.dart';
import 'recordServiceHandler_stub.dart'
    if (dart.library.io) 'recordServiceHandler.dart';

typedef RecordStatusChanged = void Function(RecordStatus status);

enum RecordStatus {
  starting(1),
  started(2),
  stopping(3),
  stopped(4);

  final int rawValue;

  const RecordStatus(this.rawValue);

  factory RecordStatus.fromRawValue(int rawValue) =>
      RecordStatus.values.firstWhere((e) => e.rawValue == rawValue);
}

class RecordService {
  RecordService._();

  static final RecordService instance = RecordService._();

  RecordStatus _prevRecordStatus = RecordStatus.stopped;
  RecordStatus _currRecordStatus = RecordStatus.stopped;

  // Web-only VAD handler
  VadHandler? _webVadHandler;
  StreamSubscription<List<double>>? _webVadSub;

  // ------------- Service API -------------
  Future<void> _requestNotificationPermission() async {
    if (kIsWeb) return;
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  Future<void> _requestRecordPermission() async {
    if (!await AudioRecorder().hasPermission()) {
      throw Exception(
          'To start record service, you must grant microphone permission.');
    }
  }

  void init() {
    if (kIsWeb) return;
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'record_service',
        channelName: 'Record Service',
        channelImportance: NotificationChannelImportance.MAX,
        priority: NotificationPriority.MAX,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> start() async {
    if (kIsWeb) {
      // On web, audio is handled via the VAD handler directly (no foreground task needed)
      _updateRecordStatus(RecordStatus.starting);
      _webVadHandler = VadHandler.create(isDebug: false);
      _webVadSub = _webVadHandler!.onSpeechEnd.listen((List<double> samples) {
        // Convert PCM samples to WAV data URL (same format as native handler)
        final wavUrl = AudioUtils.createWavUrl(samples);
        _onReceiveTaskData(wavUrl);
      });
      _webVadHandler!.onError.listen((String msg) {
        print('[WebVAD] Error: $msg');
      });
      await _webVadHandler!.startListening();
      _updateRecordStatus(RecordStatus.started);
      return;
    }
    await _requestNotificationPermission();
    await _requestRecordPermission();

    _updateRecordStatus(RecordStatus.starting);

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      serviceId: 300,
      notificationTitle: 'Record Service',
      notificationText: '',
      callback: startRecordService,
    );

    if (result is ServiceRequestFailure) {
      throw result.error;
    }

    _updateRecordStatus(RecordStatus.started);
  }

  Future<void> stop() async {
    if (kIsWeb) {
      _webVadHandler?.stopListening();
      _webVadSub?.cancel();
      _webVadHandler?.dispose();
      _webVadHandler = null;
      _webVadSub = null;
      _updateRecordStatus(RecordStatus.stopped);
      return;
    }
    _updateRecordStatus(RecordStatus.stopping);

    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    if (result is ServiceRequestFailure) {
      throw result.error;
    }

    _updateRecordStatus(RecordStatus.stopped);
  }

  Future<bool> get isRunningService =>
      kIsWeb ? Future.value(false) : FlutterForegroundTask.isRunningService;

  RecordStatus get recordStatus => _currRecordStatus;

  // ------------- Service callback -------------
  final List<RecordStatusChanged> _callbacks = [];

  void _updateRecordStatus(RecordStatus status) {
    _prevRecordStatus = _currRecordStatus;
    _currRecordStatus = status;
    for (final RecordStatusChanged callback in _callbacks.toList()) {
      callback(status);
    }
  }

  void _rollbackRecordStatus() {
    final RecordStatus prevStatus = _prevRecordStatus;
    _currRecordStatus = prevStatus;
    for (final RecordStatusChanged callback in _callbacks.toList()) {
      callback(prevStatus);
    }
  }

  void _onReceiveTaskData(Object data) async {
    if (data == 'stop') {
      stop();
      return;
    }
    print('Received task data: ${(data as String).substring(0, 50)}...');
    RecordingServer().incrementProcessedSegments();
    await RecentLogRequest().requestWithAudio(
        data as String, RecentLogHandler().getCurrentSelected);
  }

  void addRecordStatusChangedCallback(RecordStatusChanged callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
  }

  void removeRecordStatusChangedCallback(RecordStatusChanged callback) {
    _callbacks.remove(callback);
  }
}
