// Native opus initialization
import 'package:opus_dart/opus_dart.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;

Future<void> initOpusIfAvailable() async {
  initOpus(await opus_flutter.load());
}
