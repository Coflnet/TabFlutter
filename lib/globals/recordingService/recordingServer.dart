import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';

import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as soi;
import 'package:table_entry/globals/recordingService/recordService.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:opus_dart/opus_dart.dart';

import 'dart:async';
import 'dart:typed_data';

late soi.Socket? ws;

Uint8List audioBuffer = Uint8List(0);
StreamSubscription? audioStream;
StreamController<Uint8List> _audioStreamController =
    StreamController<Uint8List>();
String reconizedWords = "";
StreamSubscription? _mRecordingDataSubscription;
late WebSocketChannel channel;
String? _mPath;
late SimpleOpusEncoder encoder;
late SimpleOpusDecoder decoder;
final record = AudioRecorder();
int newNum = 0;

class RecordingServer extends ChangeNotifier {
  static final RecordingServer _instance = RecordingServer._internal();

  factory RecordingServer() {
    return _instance;
  }

  RecordingServer._internal();
  get getNewNum => newNum;

  void startStreaming() async {
    RecordService.instance.init();
    await RecordService.instance.start();
  }

  void stopRecorder() async {
    await RecordService.instance.stop();
    await record.stop();
    // TODO: dispose
  }

  String get getReconizedWords => reconizedWords;
}
