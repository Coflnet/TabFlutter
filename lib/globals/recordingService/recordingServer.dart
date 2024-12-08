import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';

import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as soi;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;

import 'dart:async';
import 'dart:typed_data';

Stream<List<int>> bufferStream(Stream<Uint8List> inputStream, int chunkSize) {
  StreamController<List<int>>? controller;
  List<int> buffer = [];

  controller = StreamController<List<int>>(onListen: () {
    inputStream.listen((newData) {
      if (newData.offsetInBytes % Int16List.bytesPerElement == 0) {
        // Offset is aligned, safe to create Int16List view
        var int16List = newData.buffer
            .asInt16List(newData.offsetInBytes, newData.lengthInBytes ~/ 2);
        buffer.addAll(int16List);
      } else {
        // Offset is not aligned, create a new aligned Uint8List
        Uint8List alignedData = Uint8List.fromList(newData);

        // Create Int16List view from the new aligned data
        var int16List = alignedData.buffer.asInt16List();
        buffer.addAll(int16List);
        print(
            "Received buffer ${alignedData.length} bytes, ${int16List.length} samples, original offset: ${newData.length} - offset ${newData.offsetInBytes}");
      }

      while (buffer.length >= chunkSize) {
        var chunk = buffer.sublist(0, chunkSize);
        buffer = buffer.sublist(chunkSize);
        controller!.add(chunk);
      }
    }, onDone: () {
      if (buffer.isNotEmpty) {
        controller!.add(buffer);
      }
      controller!.close();
    }, onError: (error) {
      controller!.addError(error);
    });
  });

  return controller.stream;
}

late soi.Socket? ws;
//final AudioRecorder recorder = AudioRecorder();

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
final recorder = FlutterSoundRecorder();

class RecordingServer extends ChangeNotifier {
  Future<void> connectSocket() async {
    await setupEncoder();
    print("connecting");

    channel =
        WebSocketChannel.connect(Uri.parse("wss://demo.coflnet.com/api/audio"));
    await channel.ready;
    channel.stream.listen((message) {
      print(message);
    });
    print("connected");
    return;
  }

  setupEncoder() async {
    initOpus(await opus_flutter.load());
    encoder = SimpleOpusEncoder(
        sampleRate: 16000, channels: 1, application: Application.voip);
    decoder = SimpleOpusDecoder(sampleRate: 16000, channels: 1);
    print(getOpusVersion());
  }

  void _handleMessage(dynamic message) {
    print("Message received: $message");
  }

  void sendMessage(data) async {
    try {
      channel.sink.add(data);
      print("Message sent: ${data.length}");
    } catch (e) {
      print("Error sending message: $e");
    }
    return;
    if (ws?.connected == true) {
      print("hi");
      ws?.emit(data);
    }
  }

  Future<void> startRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    final session = await AudioSession.instance;
    print("configuring");
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  void startStreaming() async {
    final tempDir = await getDownloadsDirectory();

    print(tempDir);
    final dir = "${tempDir!.path}/audio";

    File(dir).createSync(
      recursive: true,
    );
    var sink = await createFile("original.pcm");
    var reencode = await createFile("reencode.pcm");
    var control = await createFile("control.pcm");
    const int chunkSize = 960;
    List<int> generalBuffer = [];
    var recordingDataController = StreamController<Uint8List>();
    _mRecordingDataSubscription =
        bufferStream(recordingDataController.stream, chunkSize).listen((chunk) {
      var input = Int16List.fromList(chunk);
      sink.add(input.buffer.asUint8List());
      var result = encoder.encode(input: input);
      var decoded = decoder.decode(input: result);
      channel.sink.add(result);
      reencode.add(decoded.buffer.asUint8List());
      print("recieved data " +
          decoded.length.toString() +
          " bytes " +
          result.length.toString() +
          " samples");
    });

    await recorder.openRecorder();
    await recorder.startRecorder(
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
      bufferSize: 8192,
    );
  }

  Future<IOSink> createFile(String name) async {
    var tempDir = await getDownloadsDirectory();
    _mPath = '${tempDir!.path}/$name';
    var outputFile = File(_mPath!);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    return outputFile.openWrite();
  }

  Future<void> stopRecording() async {
    await recorder.stopRecorder();
    await recorder.closeRecorder();
  }

  String get getReconizedWords => reconizedWords;
}
