// lib/src/vad/core/vad_handler.dart

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

import 'package:table_entry/src/vad/core/vad_iterator.dart';
import 'package:table_entry/src/vad/core/vad_event.dart';

/// Platform-agnostic Voice Activity Detection handler for real-time audio processing
class VadHandler {
  final AudioRecorder _audioRecorder = AudioRecorder();
  VadIterator? _vadIterator;
  StreamSubscription<List<int>>? _audioStreamSubscription;

  bool _isDebug = false;
  bool _isInitialized = false;
  bool _submitUserSpeechOnPause = false;
  bool _isPaused = false;
  double _amplification = 4.0;
  bool _hasWarnedAboutClipping = false;

  String? _currentModel;
  int? _currentFrameSamples;
  double? _currentPositiveSpeechThreshold;
  double? _currentNegativeSpeechThreshold;
  int? _currentRedemptionFrames;
  int? _currentPreSpeechPadFrames;
  int? _currentMinSpeechFrames;
  String? _currentBaseAssetPath;
  String? _currentOnnxWASMBasePath;
  int? _currentEndSpeechPadFrames;
  int? _currentNumFramesToEmit;

  final onSpeechEndController = StreamController<List<double>>.broadcast();
  final onFrameProcessedController = StreamController<
      ({double isSpeech, double notSpeech, List<double> frame})>.broadcast();
  final onSpeechStartController = StreamController<void>.broadcast();
  final onRealSpeechStartController = StreamController<void>.broadcast();
  final onVADMisfireController = StreamController<void>.broadcast();
  final onErrorController = StreamController<String>.broadcast();
  final onEmitChunkController =
      StreamController<({List<double> samples, bool isFinal})>.broadcast();
  final onOverlapDetectedController =
      StreamController<List<double>>.broadcast();

  VadHandler._({bool isDebug = false}) {
    _isDebug = isDebug;
  }

  Stream<List<double>> get onSpeechEnd => onSpeechEndController.stream;

  Stream<({double isSpeech, double notSpeech, List<double> frame})>
      get onFrameProcessed => onFrameProcessedController.stream;

  Stream<void> get onSpeechStart => onSpeechStartController.stream;

  Stream<void> get onRealSpeechStart => onRealSpeechStartController.stream;

  Stream<void> get onVADMisfire => onVADMisfireController.stream;

  Stream<String> get onError => onErrorController.stream;

  Stream<({List<double> samples, bool isFinal})> get onEmitChunk =>
      onEmitChunkController.stream;

  Stream<List<double>> get onOverlapDetected =>
      onOverlapDetectedController.stream;

  List<double> _convertSamples(Int16List int16List) {
    final amp = _amplification;
    final result = List<double>.filled(int16List.length, 0.0);
    var clipped = false;
    for (var i = 0; i < int16List.length; i++) {
      final normalized = int16List[i] / 32768.0;
      var sample = normalized * amp;
      if (sample > 1.0) {
        sample = 1.0;
        clipped = true;
      } else if (sample < -1.0) {
        sample = -1.0;
        clipped = true;
      }
      result[i] = sample;
    }

    if (clipped && !_hasWarnedAboutClipping) {
      _hasWarnedAboutClipping = true;
      if (_isDebug) {
        print(
            'VadHandler: Audio samples clipped after amplification (factor: $amp). Consider lowering amplification.');
      }
    }

    return result;
  }

  void _handleVadEvent(VadEvent event) {
    switch (event.type) {
      case VadEventType.start:
        onSpeechStartController.add(null);
        break;
      case VadEventType.realStart:
        onRealSpeechStartController.add(null);
        break;
      case VadEventType.end:
        if (event.audioData != null) {
          final audioData = event.audioData!;
          final int16List = Int16List.view(audioData.buffer,
              audioData.offsetInBytes, audioData.lengthInBytes >> 1);
          onSpeechEndController.add(_convertSamples(int16List));
        }
        break;
      case VadEventType.frameProcessed:
        if (event.probabilities != null && event.frameData != null) {
          onFrameProcessedController.add((
            isSpeech: event.probabilities!.isSpeech,
            notSpeech: event.probabilities!.notSpeech,
            frame: event.frameData!
          ));
        }
        break;
      case VadEventType.misfire:
        onVADMisfireController.add(null);
        break;
      case VadEventType.error:
        onErrorController.add(event.message);
        break;
      case VadEventType.chunk:
        if (event.audioData != null) {
          final audioData = event.audioData!;
          final int16List = Int16List.view(audioData.buffer,
              audioData.offsetInBytes, audioData.lengthInBytes >> 1);
          onEmitChunkController.add((
            samples: _convertSamples(int16List),
            isFinal: event.isFinal ?? false
          ));
        }
        break;
      case VadEventType.overlapDetected:
        if (event.audioData != null) {
          final audioData = event.audioData!;
          final int16List = Int16List.view(audioData.buffer,
              audioData.offsetInBytes, audioData.lengthInBytes >> 1);
          onOverlapDetectedController.add(_convertSamples(int16List));
          if (_isDebug) {
            print(
                'VadHandler: Overlapping speech detected - recording should be dropped');
          }
        }
        break;
    }
  }

  Future<void> startListening(
      {double positiveSpeechThreshold = 0.3,
      double negativeSpeechThreshold = 0.2,
      int preSpeechPadFrames = 1,
      int redemptionFrames = 8,
      int frameSamples = 1536,
      int minSpeechFrames = 3,
      bool submitUserSpeechOnPause = false,
      String model = 'v4',
      String baseAssetPath =
          'https://cdn.jsdelivr.net/npm/@keyurmaru/vad@0.0.1/',
      String onnxWASMBasePath =
          'https://cdn.jsdelivr.net/npm/onnxruntime-web@1.22.0/dist/',
      RecordConfig? recordConfig,
      double amplification = 15.0,
      int endSpeechPadFrames = 1,
      int numFramesToEmit = 0,
      bool bypassPermissionCheck = false,
      bool startMicrophone = true}) async {
    if (_isDebug) {
      print('VadHandler: startListening called with model: $model');
    }

    // Adjust parameters for v5 model if using defaults
    if (model == 'v5') {
      if (preSpeechPadFrames == 1) preSpeechPadFrames = 3;
      if (redemptionFrames == 8) redemptionFrames = 24;
      if (frameSamples == 1536) frameSamples = 512;
      if (minSpeechFrames == 3) minSpeechFrames = 9;
      if (endSpeechPadFrames == 1) endSpeechPadFrames = 3;
    }

    if (_isPaused && _audioStreamSubscription != null) {
      if (_isDebug) print('VadHandler: Resuming from paused state');
      _isPaused = false;
      return;
    }

    final parametersChanged = _currentModel != model ||
        _currentFrameSamples != frameSamples ||
        _currentPositiveSpeechThreshold != positiveSpeechThreshold ||
        _currentNegativeSpeechThreshold != negativeSpeechThreshold ||
        _currentRedemptionFrames != redemptionFrames ||
        _currentPreSpeechPadFrames != preSpeechPadFrames ||
        _currentMinSpeechFrames != minSpeechFrames ||
        _currentBaseAssetPath != baseAssetPath ||
        _currentOnnxWASMBasePath != onnxWASMBasePath ||
        _currentEndSpeechPadFrames != endSpeechPadFrames ||
        _currentNumFramesToEmit != numFramesToEmit;

    if (!_isInitialized || parametersChanged) {
      if (_isDebug) {
        print(
            'VadHandler: Creating new VAD iterator - initialized: $_isInitialized, parametersChanged: $parametersChanged');
      }

      if (_vadIterator != null) {
        if (_isDebug) print('VadHandler: Releasing old VAD iterator');
        await _vadIterator?.release();
        _vadIterator = null;
      }

      if (_isDebug) {
        print('VadHandler: Creating VadIterator with model: $model');
      }

      _vadIterator = await VadIterator.create(
        isDebug: _isDebug,
        sampleRate: 16000,
        frameSamples: frameSamples,
        positiveSpeechThreshold: positiveSpeechThreshold,
        negativeSpeechThreshold: negativeSpeechThreshold,
        redemptionFrames: redemptionFrames,
        preSpeechPadFrames: preSpeechPadFrames,
        minSpeechFrames: minSpeechFrames,
        model: model,
        baseAssetPath: baseAssetPath,
        onnxWASMBasePath: onnxWASMBasePath,
        endSpeechPadFrames: endSpeechPadFrames,
        numFramesToEmit: numFramesToEmit,
      );
      _vadIterator?.setVadEventCallback(_handleVadEvent);

      _currentModel = model;
      _currentFrameSamples = frameSamples;
      _currentPositiveSpeechThreshold = positiveSpeechThreshold;
      _currentNegativeSpeechThreshold = negativeSpeechThreshold;
      _currentRedemptionFrames = redemptionFrames;
      _currentPreSpeechPadFrames = preSpeechPadFrames;
      _currentMinSpeechFrames = minSpeechFrames;
      _currentBaseAssetPath = baseAssetPath;
      _currentOnnxWASMBasePath = onnxWASMBasePath;
      _currentEndSpeechPadFrames = endSpeechPadFrames;
      _currentNumFramesToEmit = numFramesToEmit;

      _submitUserSpeechOnPause = submitUserSpeechOnPause;
      _isInitialized = true;

      if (_isDebug) print('VadHandler: VAD iterator created successfully');
    }

    if (!startMicrophone) {
      if (_isDebug) print('VadHandler: Skipping microphone start');
      return;
    }

    if (_isDebug) print('VadHandler: Checking audio permissions');

    bool hasPermission =
        bypassPermissionCheck ? true : await _audioRecorder.hasPermission();
    if (!hasPermission) {
      onErrorController.add('VadHandler: No permission to record audio.');
      print('VadHandler: No permission to record audio.');
      return;
    }

    if (_isDebug) print('VadHandler: Audio permissions granted');

    _isPaused = false;
    _amplification = amplification;
    _hasWarnedAboutClipping = false;

    final config = recordConfig ??
        const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            bitRate: 16,
            numChannels: 1,
            echoCancel: true,
            autoGain: true,
            noiseSuppress: true,
            androidConfig: AndroidRecordConfig(
              speakerphone: false,
              audioSource: AndroidAudioSource.voiceRecognition,
              audioManagerMode: AudioManagerMode.modeNormal,
            ),
            iosConfig: IosRecordConfig(
              manageAudioSession: true,
            ));

    if (_isDebug) print('VadHandler: Starting audio stream');

    try {
      final stream = await _audioRecorder.startStream(config);

      _audioStreamSubscription = stream.listen((data) async {
        if (!_isPaused) {
          await _vadIterator?.processAudioData(data);
        }
      });

      if (_isDebug) print('VadHandler: Audio stream started successfully');
    } catch (e) {
      print('VadHandler: Error starting audio stream: $e');
      onErrorController.add('Error starting audio stream: $e');
      rethrow;
    }
  }

  Future<void> processAudioData(Uint8List data) async {
    await _vadIterator?.processAudioData(data);
  }

  Future<void> stopListening() async {
    if (_isDebug) print('VadHandler: stopListening called');
    try {
      if (_submitUserSpeechOnPause) {
        _vadIterator?.forceEndSpeech();
      }

      if (_audioStreamSubscription != null) {
        if (_isDebug) print('VadHandler: Canceling audio stream subscription');
        await _audioStreamSubscription?.cancel();
        _audioStreamSubscription = null;
      }

      if (_isDebug) print('VadHandler: Stopping audio recorder');
      try {
        await _audioRecorder.stop();
      } catch (e) {
        if (_isDebug) print('VadHandler: Audio recorder stop threw: $e');
        onErrorController.add(e.toString());
      }

      if (_isDebug) print('VadHandler: Resetting VAD iterator');
      _vadIterator?.reset();
      _isPaused = false;

      if (_isDebug) print('VadHandler: stopListening completed');
    } catch (e) {
      onErrorController.add(e.toString());
      print('Error stopping audio stream: $e');
    }
  }

  Future<void> pauseListening() async {
    if (_isDebug) print('pauseListening');
    _isPaused = true;
    if (_submitUserSpeechOnPause) {
      _vadIterator?.forceEndSpeech();
    }
  }

  Future<void> dispose() async {
    if (_isDebug) print('VadHandler: dispose called');

    await stopListening();

    if (_isDebug) print('VadHandler: disposing audio recorder');
    try {
      await _audioRecorder.dispose();
    } catch (e) {
      if (_isDebug) print('VadHandler: Audio recorder dispose threw: $e');
      onErrorController.add(e.toString());
    }

    try {
      await _audioStreamSubscription?.cancel();
    } catch (_) {}
    _audioStreamSubscription = null;
    _isInitialized = false;

    _currentModel = null;
    _currentFrameSamples = null;
    _currentPositiveSpeechThreshold = null;
    _currentNegativeSpeechThreshold = null;
    _currentRedemptionFrames = null;
    _currentPreSpeechPadFrames = null;
    _currentMinSpeechFrames = null;
    _currentBaseAssetPath = null;
    _currentOnnxWASMBasePath = null;
    _currentEndSpeechPadFrames = null;
    _currentNumFramesToEmit = null;

    await _vadIterator?.release();
    onSpeechEndController.close();
    onFrameProcessedController.close();
    onSpeechStartController.close();
    onRealSpeechStartController.close();
    onVADMisfireController.close();
    onErrorController.close();
    onEmitChunkController.close();
    onOverlapDetectedController.close();
  }

  void setRedemptionFrames(int frames) {
    _vadIterator?.setRedemptionFrames(frames);
    _currentRedemptionFrames = frames;
    print('VadHandler: Updated redemption frames to $frames');
  }

  double getCurrentSpeechDuration() {
    return _vadIterator?.getCurrentSpeechDuration() ?? 0;
  }

  bool get isSpeaking => _vadIterator?.isSpeaking ?? false;

  static VadHandler create({bool isDebug = false}) {
    return VadHandler._(isDebug: isDebug);
  }
}
