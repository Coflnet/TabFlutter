import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, ValueNotifier;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
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

  // Web-only VAD handler. Kept for the app's lifetime so the model and ONNX
  // session are loaded once (see [preload]) instead of on every start.
  VadHandler? _webVadHandler;
  bool _stopRequested = false;

  /// True from tapping start until the speech model is loaded and audio flows.
  /// The UI shows "preparing" instead of "listening" meanwhile.
  final ValueNotifier<bool> preparing = ValueNotifier(false);
  Timer? _readyTimeout;

  // Error callback – fires for both web and native errors
  void Function(String error)? onError;

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
    final recorder = AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        throw 'To start record service, you must grant microphone permission.';
      }
    } finally {
      await recorder.dispose();
    }
  }

  VadHandler _webHandler() =>
      _webVadHandler ??= VadHandler.create(isDebug: false)
        ..onSpeechEnd.listen((List<double> samples) {
          // Convert PCM samples to WAV data URL (same format as native handler)
          _onReceiveTaskData(AudioUtils.createWavUrl(samples));
        })
        ..onError.listen((String msg) {
          print('[WebVAD] Error: $msg');
          if (_currRecordStatus != RecordStatus.stopped) {
            _onReceiveTaskData('ERROR: $msg');
          }
        });

  /// Web: loads the VAD model and ONNX runtime in the background after the
  /// app is shown, so the first tap on the microphone starts immediately.
  /// Failures are only logged; [start] retries the load.
  Future<void> preload() async {
    if (!kIsWeb) return;
    try {
      await _webHandler().startListening(startMicrophone: false);
    } catch (e) {
      print('[WebVAD] Preload failed, will retry on start: $e');
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
    preparing.value = true;
    _stopRequested = false;
    if (kIsWeb) {
      // On web, audio is handled via the VAD handler directly (no foreground task needed)
      _updateRecordStatus(RecordStatus.starting);
      try {
        await _webHandler().startListening();
        if (_stopRequested) {
          // Stop was tapped while the model was still loading.
          await _webVadHandler?.stopListening();
          return;
        }
        preparing.value = false;
        _updateRecordStatus(RecordStatus.started);
      } catch (e) {
        print('[WebVAD] Exception on start: $e');
        preparing.value = false;
        _updateRecordStatus(RecordStatus.stopped);
        rethrow;
      }
      return;
    }
    try {
      await _requestNotificationPermission();
      await _requestRecordPermission();
      // A service left over from a crash or swipe-away would make startService
      // fail with ServiceAlreadyStarted on every tap.
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (_) {
      preparing.value = false;
      rethrow;
    }
    // Stop tapped while the permission prompts were open.
    if (_stopRequested) return;

    _updateRecordStatus(RecordStatus.starting);

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      serviceId: 300,
      notificationTitle: 'Record Service',
      notificationText: '',
      callback: startRecordService,
    );

    if (result is ServiceRequestFailure) {
      preparing.value = false;
      _updateRecordStatus(RecordStatus.stopped);
      throw result.error;
    }

    if (_stopRequested) {
      await FlutterForegroundTask.stopService();
      _updateRecordStatus(RecordStatus.stopped);
      return;
    }
    _updateRecordStatus(RecordStatus.started);
    // The service isolate reports READY once the model is loaded; never leave
    // the user on "preparing" forever.
    _readyTimeout?.cancel();
    _readyTimeout = Timer(const Duration(seconds: 30), () {
      if (preparing.value) {
        _onReceiveTaskData('ERROR: Speech model could not be loaded in time.');
      }
    });
  }

  Future<void> stop() async {
    _readyTimeout?.cancel();
    preparing.value = false;
    _stopRequested = true;
    if (kIsWeb) {
      // Pause instead of dispose: the loaded model is reused by the next start.
      await _webVadHandler?.stopListening();
      _updateRecordStatus(RecordStatus.stopped);
      return;
    }
    if (_currRecordStatus == RecordStatus.stopped) return;
    _updateRecordStatus(RecordStatus.stopping);

    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    // Whatever the plugin reports, the UI must not stay in "stopping".
    _updateRecordStatus(RecordStatus.stopped);
    if (result is ServiceRequestFailure) {
      print('[RecordService] stopService failed: ${result.error}');
    }
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

  void _onReceiveTaskData(Object data) async {
    if (data == 'stop') {
      stop();
      return;
    }
    final dataStr = data as String;

    if (dataStr == 'READY') {
      _readyTimeout?.cancel();
      preparing.value = false;
      return;
    }

    // Handle error messages from the native background isolate
    if (dataStr.startsWith('ERROR:')) {
      final errorMsg = dataStr.substring(6).trim();
      print('[RecordService] Native error: $errorMsg');
      onError?.call(errorMsg);
      stop();
      return;
    }

    print(
        'Received task data: ${dataStr.substring(0, dataStr.length.clamp(0, 50))}...');
    RecordingServer().incrementProcessedSegments();
    await RecentLogRequest()
        .requestWithAudio(dataStr, RecentLogHandler().getCurrentSelected);
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
