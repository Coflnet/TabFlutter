// lib/src/vad/core/vad_iterator.dart
// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:table_entry/src/vad/core/overlap_detector.dart';
import 'package:table_entry/src/vad/core/vad_event.dart';
import 'package:table_entry/src/vad/core/vad_inference.dart';
import 'package:table_entry/src/vad/utils/model_utils.dart';

/// Callback function type for receiving VAD events during audio processing
typedef VadEventCallback = void Function(VadEvent event);

/// Low-level Voice Activity Detection iterator for direct audio processing
class VadIterator {
  final bool _isDebug;
  final double _positiveSpeechThreshold;
  final double _negativeSpeechThreshold;
  int _redemptionFrames;
  final int _frameSamples;
  final int _preSpeechPadFrames;
  final int _endSpeechPadFrames;
  final int _minSpeechFrames;
  final int _numFramesToEmit;
  final int _sampleRate;
  final VadInference _inference;

  bool _speaking = false;
  int _redemptionCounter = 0;
  int _speechPositiveFrameCount = 0;
  int _currentSample = 0;

  final List<Float32List> _preSpeechBuffer = [];
  final List<Float32List> _speechBuffer = [];

  int _speechStartIndex = 0;
  int _sentRedemptionFrames = 0;

  VadEventCallback? _onVadEvent;

  final List<int> _byteBuffer = [];
  final int _frameByteCount;

  int _totalFramesProcessed = 0;
  bool _speechRealStartFired = false;

  final OverlapDetector _overlapDetector;
  final bool _detectOverlap;

  VadIterator._({
    required bool isDebug,
    required int sampleRate,
    required int frameSamples,
    required double positiveSpeechThreshold,
    required double negativeSpeechThreshold,
    required int redemptionFrames,
    required int preSpeechPadFrames,
    required int minSpeechFrames,
    required int endSpeechPadFrames,
    required int numFramesToEmit,
    required VadInference inference,
    bool detectOverlap = false,
  })  : _isDebug = isDebug,
        _sampleRate = sampleRate,
        _frameSamples = frameSamples,
        _positiveSpeechThreshold = positiveSpeechThreshold,
        _negativeSpeechThreshold = negativeSpeechThreshold,
        _redemptionFrames = redemptionFrames,
        _preSpeechPadFrames = preSpeechPadFrames,
        _minSpeechFrames = minSpeechFrames,
        _endSpeechPadFrames = endSpeechPadFrames,
        _numFramesToEmit = numFramesToEmit,
        _inference = inference,
        _frameByteCount = frameSamples * 2,
        _detectOverlap = detectOverlap,
        _overlapDetector = OverlapDetector(
          sampleRate: sampleRate,
          frameSize: frameSamples,
        );

  void reset() {
    if (_isDebug) {
      print(
          'VadIteratorImpl: Resetting state (processed $_totalFramesProcessed frames so far)');
    }
    _speaking = false;
    _redemptionCounter = 0;
    _speechPositiveFrameCount = 0;
    _currentSample = 0;
    _speechStartIndex = 0;
    _sentRedemptionFrames = 0;
    _speechRealStartFired = false;
    _preSpeechBuffer.clear();
    _speechBuffer.clear();
    _byteBuffer.clear();
    _totalFramesProcessed = 0;
    _inference.model.resetState();
    _overlapDetector.reset();
  }

  Future<void> release() async {
    await _inference.release();
  }

  void setVadEventCallback(VadEventCallback callback) {
    _onVadEvent = callback;
  }

  void setRedemptionFrames(int frames) {
    if (_isDebug) {
      print(
          'VadIterator: Updating redemptionFrames from $_redemptionFrames to $frames');
    }
    _redemptionFrames = frames;
  }

  double getCurrentSpeechDuration() {
    if (!_speaking) return 0;
    return _speechBuffer.length * _frameSamples / _sampleRate;
  }

  bool get isSpeaking => _speaking;

  OverlapAnalysis getOverlapAnalysis() => _overlapDetector.getAnalysis();

  bool get hasOverlappingSpeech =>
      _detectOverlap && _overlapDetector.getAnalysis().hasOverlap;

  Future<void> processAudioData(Uint8List data) async {
    _byteBuffer.addAll(data);

    while (_byteBuffer.length >= _frameByteCount) {
      final frameBytes = _byteBuffer.sublist(0, _frameByteCount);
      _byteBuffer.removeRange(0, _frameByteCount);
      final frameData = _convertBytesToFloat32(Uint8List.fromList(frameBytes));
      await _processFrame(Float32List.fromList(frameData));
    }
  }

  Future<void> _processFrame(Float32List data) async {
    if (data.length != _frameSamples) {
      print(
          'VadIteratorImpl: Unexpected frame size: ${data.length}, expected: $_frameSamples');
      return;
    }

    _totalFramesProcessed++;

    try {
      final speechProb = await _runModelInference(data);

      final frameData = data.toList();

      _onVadEvent?.call(VadEvent(
        type: VadEventType.frameProcessed,
        timestamp: _getCurrentTimestamp(),
        message:
            'Frame processed at ${_getCurrentTimestamp().toStringAsFixed(3)}s',
        probabilities: SpeechProbabilities(
            isSpeech: speechProb, notSpeech: 1.0 - speechProb),
        frameData: frameData,
      ));

      _currentSample += _frameSamples;
      _handleStateTransitions(speechProb, data);
    } catch (e, stackTrace) {
      print('VadIteratorImpl: Error in _processFrame: $e');
      print('Stack trace: $stackTrace');

      _onVadEvent?.call(VadEvent(
        type: VadEventType.error,
        timestamp: _getCurrentTimestamp(),
        message: 'Frame processing error: $e',
      ));
    }
  }

  Future<double> _runModelInference(Float32List data) async {
    try {
      final probs = await _inference.model.process(data);
      return probs.isSpeech;
    } catch (e) {
      print('VadIteratorImpl: Model inference error: $e');
      rethrow;
    }
  }

  void _handleStateTransitions(double speechProb, Float32List data) {
    if (speechProb >= _positiveSpeechThreshold) {
      if (!_speaking) {
        _speaking = true;
        _speechStartIndex = 0;
        _speechRealStartFired = false;
        if (_detectOverlap) {
          _overlapDetector.reset();
        }
        if (_isDebug) {
          print(
              'VadIteratorImpl: Speech started (prob: ${speechProb.toStringAsFixed(3)})');
        }
        _onVadEvent?.call(VadEvent(
          type: VadEventType.start,
          timestamp: _getCurrentTimestamp(),
          message:
              'Speech started at ${_getCurrentTimestamp().toStringAsFixed(3)}s',
        ));
        _speechBuffer.addAll(_preSpeechBuffer);
        _preSpeechBuffer.clear();
      }

      if (_detectOverlap) {
        _overlapDetector.analyzeFrame(data);
      }

      _redemptionCounter = 0;
      _sentRedemptionFrames = 0;
      _speechBuffer.add(data);
      _speechPositiveFrameCount++;

      if (_speechPositiveFrameCount == _minSpeechFrames &&
          !_speechRealStartFired) {
        _speechRealStartFired = true;
        if (_isDebug) {
          print('VadIteratorImpl: Real speech validated');
        }
        _onVadEvent?.call(VadEvent(
          type: VadEventType.realStart,
          timestamp: _getCurrentTimestamp(),
          message:
              'Speech validated at ${_getCurrentTimestamp().toStringAsFixed(3)}s',
        ));
      }
    } else if (speechProb < _negativeSpeechThreshold) {
      _handleSpeechNegativeFrame(data);
    } else {
      _handleIntermediateFrame(data);
    }

    if (_speaking &&
        _numFramesToEmit > 0 &&
        _speechBuffer.length - _speechStartIndex >= _numFramesToEmit &&
        _redemptionCounter <= _endSpeechPadFrames) {
      final framesToSend = _speechBuffer.sublist(
          _speechStartIndex, _speechStartIndex + _numFramesToEmit);
      _speechStartIndex = _speechStartIndex + _numFramesToEmit;
      _sentRedemptionFrames = _redemptionCounter;
      _emitChunkEvent(framesToSend,
          'Audio chunk emitted at ${_getCurrentTimestamp().toStringAsFixed(3)}s');
    }
  }

  void _handleSpeechNegativeFrame(Float32List data) {
    if (_speaking) {
      _speechBuffer.add(data);
      _redemptionCounter++;

      if (_redemptionCounter >= _redemptionFrames) {
        _speaking = false;
        _redemptionCounter = 0;

        if (_speechPositiveFrameCount >= _minSpeechFrames) {
          final overlapAnalysis =
              _detectOverlap ? _overlapDetector.getAnalysis() : null;
          final hasOverlap = overlapAnalysis?.hasOverlap ?? false;

          final framesToRemove = _redemptionFrames - _endSpeechPadFrames;
          const startIndex = 0;

          final audioBufferPad = _processAudioBuffer(
            frames: _speechBuffer,
            startIndex: startIndex,
            framesToRemove: framesToRemove,
          );

          final audio = _combineFrames(audioBufferPad);

          if (hasOverlap) {
            _onVadEvent?.call(VadEvent(
              type: VadEventType.overlapDetected,
              timestamp: _getCurrentTimestamp(),
              message:
                  'Overlapping speech detected at ${_getCurrentTimestamp().toStringAsFixed(3)}s - recording dropped',
              audioData: audio,
            ));
          } else {
            _onVadEvent?.call(VadEvent(
              type: VadEventType.end,
              timestamp: _getCurrentTimestamp(),
              message:
                  'Speech ended at ${_getCurrentTimestamp().toStringAsFixed(3)}s',
              audioData: audio,
            ));
          }

          if (!hasOverlap) {
            _handleFinalChunkEmission();
          }
        } else {
          if (_isDebug) {
            print(
                'VadIteratorImpl: Misfire (only $_speechPositiveFrameCount positive frames)');
          }
          _onVadEvent?.call(VadEvent(
            type: VadEventType.misfire,
            timestamp: _getCurrentTimestamp(),
            message:
                'Misfire detected at ${_getCurrentTimestamp().toStringAsFixed(3)}s',
          ));
        }

        _speechPositiveFrameCount = 0;
        _speechStartIndex = 0;
        _sentRedemptionFrames = 0;
        _speechRealStartFired = false;

        if (_endSpeechPadFrames < _redemptionFrames) {
          final framesToKeep = _speechBuffer.sublist(
              _speechBuffer.length - (_redemptionFrames - _endSpeechPadFrames));
          _speechBuffer.clear();
          _preSpeechBuffer.clear();
          _preSpeechBuffer.addAll(framesToKeep);
          while (_preSpeechBuffer.length > _preSpeechPadFrames) {
            _preSpeechBuffer.removeAt(0);
          }
        } else {
          _speechBuffer.clear();
        }
      }
    } else {
      _addToPreSpeechBuffer(data);
    }
  }

  void _handleIntermediateFrame(Float32List data) {
    if (_speaking) {
      _speechBuffer.add(data);
      _redemptionCounter = 0;
    } else {
      _addToPreSpeechBuffer(data);
    }
  }

  void forceEndSpeech() {
    if (_speaking && _speechPositiveFrameCount >= _minSpeechFrames) {
      if (_isDebug) print('VadIteratorImpl: Forcing speech end.');
      _onVadEvent?.call(VadEvent(
        type: VadEventType.end,
        timestamp: _getCurrentTimestamp(),
        message:
            'Speech forcefully ended at ${_getCurrentTimestamp().toStringAsFixed(3)}s',
        audioData: _combineFrames(_speechBuffer),
      ));
      _speaking = false;
      _redemptionCounter = 0;
      _speechPositiveFrameCount = 0;
      _speechBuffer.clear();
      _preSpeechBuffer.clear();
      _speechStartIndex = 0;
      _sentRedemptionFrames = 0;
      _speechRealStartFired = false;
    }
  }

  void _addToPreSpeechBuffer(Float32List data) {
    _preSpeechBuffer.add(data);
    while (_preSpeechBuffer.length > _preSpeechPadFrames) {
      _preSpeechBuffer.removeAt(0);
    }
  }

  double _getCurrentTimestamp() {
    return _currentSample / _sampleRate;
  }

  Uint8List _combineFrames(List<Float32List> frames) {
    final int totalLength = frames.fold(0, (sum, frame) => sum + frame.length);
    final Float32List combined = Float32List(totalLength);
    int offset = 0;
    for (var frame in frames) {
      combined.setRange(offset, offset + frame.length, frame);
      offset += frame.length;
    }
    final int16Data = Int16List.fromList(
        combined.map((e) => (e * 32767).clamp(-32768, 32767).toInt()).toList());
    final Uint8List audioData = Uint8List.view(int16Data.buffer);
    return audioData;
  }

  void _addSilencePadding(List<Float32List> frames, int paddingFrames) {
    for (int i = 0; i < paddingFrames; i++) {
      frames.add(Float32List(_frameSamples));
    }
  }

  List<Float32List> _processAudioBuffer({
    required List<Float32List> frames,
    required int startIndex,
    required int framesToRemove,
  }) {
    List<Float32List> result;

    if (framesToRemove > 0) {
      final endIndex =
          (frames.length - framesToRemove).clamp(startIndex, frames.length);
      result = frames.sublist(startIndex, endIndex);
    } else {
      result = frames.sublist(startIndex);
      _addSilencePadding(result, -framesToRemove);
    }

    return result;
  }

  void _emitChunkEvent(List<Float32List> frames, String message,
      {bool isFinal = false}) {
    final audioData = _combineFrames(frames);
    _onVadEvent?.call(VadEvent(
      type: VadEventType.chunk,
      timestamp: _getCurrentTimestamp(),
      message: message,
      audioData: audioData,
      isFinal: isFinal,
    ));
  }

  void _handleFinalChunkEmission() {
    if (_numFramesToEmit <= 0) return;

    final int endFramesToRemove;
    if (_sentRedemptionFrames == 0) {
      endFramesToRemove = _redemptionFrames - _endSpeechPadFrames;
    } else {
      endFramesToRemove = _sentRedemptionFrames - _endSpeechPadFrames;
    }

    if (_speechStartIndex < _speechBuffer.length || endFramesToRemove < 0) {
      final frames = _processAudioBuffer(
        frames: _speechBuffer,
        startIndex: _speechStartIndex,
        framesToRemove: endFramesToRemove,
      );

      if (frames.isNotEmpty) {
        _emitChunkEvent(frames,
            'Final audio chunk emitted at ${_getCurrentTimestamp().toStringAsFixed(3)}s',
            isFinal: true);
      }
    }
  }

  List<double> _convertBytesToFloat32(Uint8List data) {
    final buffer = data.buffer;
    final int16List = Int16List.view(buffer);
    return int16List.map((e) => e / 32768.0).toList();
  }

  static Future<VadIterator> create({
    required bool isDebug,
    required int sampleRate,
    required int frameSamples,
    required double positiveSpeechThreshold,
    required double negativeSpeechThreshold,
    required int redemptionFrames,
    required int preSpeechPadFrames,
    required int minSpeechFrames,
    required String model,
    String baseAssetPath = 'packages/vad/companion-package/',
    String onnxWASMBasePath =
        'https://cdn.jsdelivr.net/npm/onnxruntime-web@1.22.0/dist/',
    int endSpeechPadFrames = 1,
    int numFramesToEmit = 0,
    dynamic threadingConfig,
  }) async {
    final modelPath = await getModelPath(baseAssetPath, model);

    final inference = await VadInference.create(
      model: model,
      modelPath: modelPath,
      sampleRate: sampleRate,
      isDebug: isDebug,
      onnxWASMBasePath: onnxWASMBasePath,
      threadingConfig: threadingConfig,
    );

    return VadIterator._(
      isDebug: isDebug,
      sampleRate: sampleRate,
      frameSamples: frameSamples,
      positiveSpeechThreshold: positiveSpeechThreshold,
      negativeSpeechThreshold: negativeSpeechThreshold,
      redemptionFrames: redemptionFrames,
      preSpeechPadFrames: preSpeechPadFrames,
      minSpeechFrames: minSpeechFrames,
      endSpeechPadFrames: endSpeechPadFrames,
      numFramesToEmit: numFramesToEmit,
      inference: inference,
    );
  }
}
