// lib/src/vad/platform/web/inference/silero_v5_model.dart

// ignore_for_file: public_member_api_docs, avoid_print

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:table_entry/src/vad/platform/web/onnxruntime/onnx_runtime_web.dart';
import 'package:table_entry/src/vad/utils/model_utils.dart';
import 'package:table_entry/src/vad/core/vad_event.dart';
import 'package:table_entry/src/vad/core/vad_model.dart';

class SileroV5Model implements VadModel {
  final InferenceSession _session;
  final Map<String, String> _inputNames;
  final Map<String, String> _outputNames;
  Tensor? _state;
  Tensor? _sr;
  Future<void>? _currentProcessing;
  int _processCount = 0;

  SileroV5Model._(this._session, this._inputNames, this._outputNames) {
    resetState();
  }

  static Future<SileroV5Model> create(String modelUrl,
      [String? onnxWASMBasePath]) async {
    try {
      final wasmPath = onnxWASMBasePath ??
          'https://cdn.jsdelivr.net/npm/onnxruntime-web@1.22.0/dist/';
      final normalizedWasmPath =
          wasmPath.endsWith('/') ? wasmPath : '$wasmPath/';

      final cachedWasmSimd =
          await getCachedBlobUrl('${normalizedWasmPath}ort-wasm-simd.wasm');
      final cachedWasm =
          await getCachedBlobUrl('${normalizedWasmPath}ort-wasm.wasm');

      final wasmPathsObj = {
        'ort-wasm-simd.wasm': cachedWasmSimd,
        'ort-wasm.wasm': cachedWasm,
      }.jsify()!;

      ort.env.wasm.wasmPaths = wasmPathsObj;

      final cachedModelUrl = await getCachedBlobUrl(modelUrl);
      final session =
          await ort.InferenceSession.create(cachedModelUrl.toJS).toDart;
      final inputNames = getModelInputNames('v5');
      final outputNames = getModelOutputNames('v5');

      return SileroV5Model._(session, inputNames, outputNames);
    } catch (e) {
      print('Error creating SileroV5Model: $e');
      rethrow;
    }
  }

  @override
  void resetState() {
    final zeroes = Float32List(2 * 1 * 128);
    _state = (ort.Tensor as JSFunction).callAsConstructor(
      'float32'.toJS,
      zeroes.toJS,
      [2, 1, 128].map((e) => e.toJS).toList().toJS,
    ) as Tensor;

    final srArray = [16000].map((e) => e.toJS).toList().toJS;
    _sr = (ort.Tensor as JSFunction).callAsConstructor(
      'int64'.toJS,
      srArray,
      [1].map((e) => e.toJS).toList().toJS,
    ) as Tensor;
  }

  @override
  Future<SpeechProbabilities> process(Float32List frame) async {
    await _currentProcessing;
    final processingFuture = _processFrameInternal(frame);
    _currentProcessing = processingFuture.then((_) {});
    return processingFuture;
  }

  Future<SpeechProbabilities> _processFrameInternal(Float32List frame) async {
    try {
      _processCount++;

      final inputTensor = (ort.Tensor as JSFunction).callAsConstructor(
        'float32'.toJS,
        frame.toJS,
        [1, frame.length].map((e) => e.toJS).toList().toJS,
      ) as Tensor;

      final feeds = {
        _inputNames['input']!: inputTensor,
        _inputNames['state']!: _state!,
        _inputNames['sr']!: _sr!,
      }.jsify()! as JSObject;

      final results = await _session.run(feeds).toDart;

      final output = results[_outputNames['output']!];
      final newState = results[_outputNames['state']!];

      _state = newState;

      final prob = (output.data.toDart)[0];
      return SpeechProbabilities(
        isSpeech: prob,
        notSpeech: 1.0 - prob,
      );
    } catch (e) {
      print('Error in SileroV5Model.process: $e');
      print('Process count when error occurred: $_processCount');
      rethrow;
    }
  }

  @override
  Future<void> release() async {
    await _session.release().toDart;
  }
}
