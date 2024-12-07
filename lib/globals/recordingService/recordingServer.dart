import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_streamer/audio_streamer.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

import 'package:socket_io_client/socket_io_client.dart' as soi;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart' show Level;

late soi.Socket? ws;

//final AudioRecorder recorder = AudioRecorder();

Uint8List audioBuffer = Uint8List(0);
StreamSubscription? audioStream;
StreamController<Uint8List> _audioStreamController =
    StreamController<Uint8List>();
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
    await recorder.openRecorder();

    recorder.setLogLevel(Level.error);

    Future<void> stopRecording() async {}
  }

  void startStreaming() async {
    final dir = "audio";
    recorder.startRecorder(sampleRate: 16000, toFile: dir, codec: Codec.pcm16);

    Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      print(
          "\n\n\n\n\n\n\n\n\n ${await recorder.isEncoderSupported(Codec.pcm16)}");
      final dir = await recorder.stopRecorder();

      if (dir == null) {
        print("null");
      }

      final tempDir = await getTemporaryDirectory();
      final outFile = "${tempDir.path}/opusAudio.opus";

      final command = [
        '-y',
        '-ar', '16000', // Sample rate (adjust based on your PCM data)
        '-ac', '1', // Number of audio channels (adjust if needed)
        '-i', dir ?? "", // Input file
        '-c:a', 'opus', // Codec: Opus
        '-b:a', '64k', // Bitrate (adjust as needed)
        '-strict', '-2',
        outFile, // Output file
      ];

      final result = await FFmpegKit.executeWithArgumentsAsync(command);

      if (await result.getReturnCode() != ReturnCode(0)) {
        final fuckingErrors = await result.getLogs();

        for (var fuck in fuckingErrors) {
          print(fuck.getMessage());
        }

        print(
            "something went from encoding to opus with ffmpeg ${fuckingErrors[0].getMessage()}");
      }

      File file = File(dir ?? "");

      Uint8List audioData = await file.readAsBytes();

      print("audio data output is ${audioData.length}");
      await recorder.startRecorder(
          sampleRate: 16000,
          numChannels: 1,
          toFile: 'audio',
          codec: Codec.pcm16);
      sendMessage(audioData);

      return;
    });
  }

  String get getReconizedWords => reconizedWords;
}
