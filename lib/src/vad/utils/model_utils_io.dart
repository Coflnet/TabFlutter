// lib/src/vad/utils/model_utils_io.dart

import 'dart:io';
import 'package:flutter/services.dart' show ByteData;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> writeModelToFile(ByteData byteData, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final tempFile = File(p.join(tempDir.path, fileName));
  await tempFile.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  print('Model copied to temporary file: ${tempFile.path}');
  return tempFile.path;
}
