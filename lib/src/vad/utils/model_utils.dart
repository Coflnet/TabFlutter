// lib/src/vad/utils/model_utils.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;

// Conditional imports for platform-specific functionality
import 'model_utils_stub.dart'
    if (dart.library.io) 'model_utils_io.dart'
    if (dart.library.js_interop) 'model_utils_web.dart' as platform;

/// Returns the URL for the Silero VAD model based on the model version.
String getModelUrl(String baseAssetPath, String model) {
  final modelFileName =
      model == 'v4' ? 'silero_vad.onnx' : 'silero_vad_v5.onnx';
  return '$baseAssetPath$modelFileName';
}

Future<String> getModelPath(String assetPath, String model) async {
  final modelFileName =
      model == 'v4' ? 'silero_vad_legacy.onnx' : 'silero_vad_v5.onnx';

  // Try loading from assets/models/ (Tab project layout)
  final tabAssetPath = p.join('assets/models', modelFileName);

  ByteData? byteData;
  String? loadedPath;

  for (final path in [tabAssetPath]) {
    try {
      byteData = await rootBundle.load(path);
      loadedPath = path;
      print('Successfully loaded model from asset path: $loadedPath');
      break;
    } catch (e) {
      print('Info: Failed to load model from asset path: $path');
    }
  }

  if (byteData != null) {
    if (kIsWeb) {
      // For web, return the asset path as a URL that can be fetched
      return 'assets/$loadedPath';
    } else {
      // For native platforms, write the asset to a temporary file
      return await platform.writeModelToFile(byteData, modelFileName);
    }
  }

  // Fallback to URL if local asset fails
  print('Failed to load model from any local asset path. Falling back to URL.');
  return getModelUrl(
      'https://cdn.jsdelivr.net/npm/@keyurmaru/vad@0.0.1/', model);
}

Map<String, String> getModelInputNames(String model) {
  if (model == 'v5') {
    return {
      'input': 'input',
      'state': 'state',
      'sr': 'sr',
    };
  } else {
    return {
      'input': 'input',
      'h': 'h',
      'c': 'c',
      'sr': 'sr',
    };
  }
}

Map<String, String> getModelOutputNames(String model) {
  if (model == 'v5') {
    return {
      'output': 'output',
      'state': 'stateN',
    };
  } else {
    return {
      'output': 'output',
      'h': 'hn',
      'c': 'cn',
    };
  }
}

/// Get output indices for native platform (ONNX Runtime returns outputs as array)
Map<String, int> getModelOutputIndices(String model) {
  if (model == 'v5') {
    return {
      'output': 0,
      'state': 1,
    };
  } else {
    return {
      'output': 0,
      'h': 1,
      'c': 2,
    };
  }
}
