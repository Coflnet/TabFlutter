// lib/src/vad/core/vad_inference.dart

import 'package:table_entry/src/vad/core/vad_model.dart';
import 'package:table_entry/src/vad/platform/web/inference/vad_inference_impl.dart'
    if (dart.library.io) 'package:table_entry/src/vad/platform/native/inference/vad_inference_impl.dart'
    as implementation;

/// Abstract interface for VAD inference operations
abstract class VadInference {
  /// Create a VAD inference instance for the specified model
  static Future<VadInference> create({
    required String model,
    required String modelPath,
    required int sampleRate,
    required bool isDebug,
    String? onnxWASMBasePath,
    dynamic threadingConfig,
  }) {
    return implementation.createVadInference(
      model: model,
      modelPath: modelPath,
      sampleRate: sampleRate,
      isDebug: isDebug,
      onnxWASMBasePath: onnxWASMBasePath,
      threadingConfig: threadingConfig,
    );
  }

  /// Get the underlying VAD model for processing
  VadModel get model;

  /// Release resources and cleanup
  Future<void> release();
}
