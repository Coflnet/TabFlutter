// lib/src/vad/utils/model_utils_web.dart

import 'package:flutter/services.dart' show ByteData;

Future<String> writeModelToFile(ByteData byteData, String fileName) async {
  // On web, we don't need to write to a file
  throw UnsupportedError('File writing not supported on web');
}
