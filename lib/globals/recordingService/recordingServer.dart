import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;

import 'package:socket_io_client/socket_io_client.dart' as soi;
import 'package:web_socket_channel/web_socket_channel.dart';

late soi.Socket? ws;

//final AudioRecorder recorder = AudioRecorder();
final encoder = SimpleOpusEncoder(
    sampleRate: 48000, channels: 1, application: Application.voip);
List<double> audioBuffer = [];
StreamSubscription? audioStream;
  StreamController<Food> _audioStreamController = StreamController<Food>();
String reconizedWords = "";
late WebSocketChannel channel;
final FlutterSoundRecorder recorder = FlutterSoundRecorder();

class RecordingServer extends ChangeNotifier {
  Future<void> connectSocket() async {
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

  void _handleMessage(dynamic message) {
    print("Message received: $message");
  }

  void sendMessage(data) async {
    channel.sink.add(data);
    return;
    if (ws?.connected == true) {
      print("hi");
      ws?.emit(data);
    }
  }

  Future<void> startRecorder() async {
    initOpus(await opus_flutter.load());
    await recorder.openRecorder();


  void onAudio(List<double> buffer) {
    audioBuffer.addAll(buffer);
  }

  Future<void> stopRecording() async {}

  void startStreaming() {
      

   recorder.startRecorder(
      codec: Codec.pcm16, // Use raw PCM for byte stream
      toStream: _audioStreamController.sink,
    );

      

    _audioStreamController.stream.listen((data) {
      // Handle the raw byte data from the microphone
      print("Audio bytes: ${data.length} bytes");
    }); 

    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (audioBuffer.isNotEmpty) {
        final chunk = get300msChunk();
        if (chunk != null) {
          sendMessage(convertToOpus(Int16List.fromList(chunk));
          return;
        }
      }
    });
  }

  Uint8List convertToOpus(Int16List data) {
    return encoder.encode(input: data);
  }

  List<double>? get300msChunk() {
    const int sampleRate = 44100;
    const int channels = 1;
    const int bytesPerCan = 2;

    const int bytesNeeded = (sampleRate * channels * bytesPerCan * 60) ~/ 1000;

    List<double> chunk = [];
    chunk.addAll(audioBuffer);

    audioBuffer = [];

    return chunk;
  }

  String get getReconizedWords => reconizedWords;
}
