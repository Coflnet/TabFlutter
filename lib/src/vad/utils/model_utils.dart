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

/// CDN fallback URLs for when local assets are unavailable or corrupted (e.g. Git LFS pointers).
String _getCdnFallbackUrl(String model) {
  if (model == 'v5') {
    return 'https://huggingface.co/onnx-community/silero-vad/resolve/main/onnx/model.onnx';
  }
  return 'https://cdn.jsdelivr.net/gh/snakers4/silero-vad@v4.0/files/silero_vad.onnx';
}

/// Minimum expected model size in bytes.  Anything smaller is likely a
/// Git LFS pointer file (~132 bytes) rather than a real ONNX model.
const int _minModelSizeBytes = 1000;

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
      print('Successfully loaded model from asset path: $loadedPath '
          '(${byteData.lengthInBytes} bytes)');
      break;
    } catch (e) {
      print('Info: Failed to load model from asset path: $path');
    }
  }

  if (byteData != null) {
    // Validate that the loaded data is an actual ONNX model, not a Git LFS
    // pointer file.  LFS pointers are ~132 bytes; real models are >100 KB.
    if (byteData.lengthInBytes < _minModelSizeBytes) {
      print('WARNING: Model asset "$loadedPath" is only '
          '${byteData.lengthInBytes} bytes – likely a Git LFS pointer. '
          'Falling back to CDN.');
      final cdnUrl = _getCdnFallbackUrl(model);
      print('Using CDN model URL: $cdnUrl');
      return cdnUrl;
    }

    if (kIsWeb) {
      // For web, return the asset path as a URL that can be fetched
      return 'assets/$loadedPath';
    } else {
      // For native platforms, write the asset to a temporary file
      return await platform.writeModelToFile(byteData, modelFileName);
    }
  }

  // Fallback to CDN URL if local asset fails entirely
  print('Failed to load model from any local asset path. Falling back to CDN.');
  final cdnUrl = _getCdnFallbackUrl(model);
  print('Using CDN model URL: $cdnUrl');
  return cdnUrl;
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
