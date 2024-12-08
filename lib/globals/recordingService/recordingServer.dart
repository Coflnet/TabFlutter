import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:socket_io_client/socket_io_client.dart' as soi;
import 'package:web_socket_channel/web_socket_channel.dart';

late soi.Socket? ws;

//final AudioRecorder recorder = AudioRecorder();

Uint8List audioBuffer = Uint8List(0);
StreamSubscription? audioStream;
StreamController<Uint8List> _audioStreamController =
    StreamController<Uint8List>();
String reconizedWords = "";
late WebSocketChannel channel;
final AudioRecorder recorder = AudioRecorder();

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
    final session = await AudioSession.instance;
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

    Future<void> stopRecording() async {}
  }

  void startStreaming() async {
    final tempDir = await getDownloadsDirectory();

    print(tempDir);
    final dir = "${tempDir!.path}/audio";

    File(dir).createSync();

    recorder.start(
        const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000, // Ensure this matches
            numChannels: 1),
        path: dir);

    Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      final dire = await recorder.stop();

      final outFile = "${tempDir.path}/opusAudio.opus";

      final command = [
        '-y',
        '-f', 's16le',
        '-ar', '16000', // Sample rate (adjust based on your PCM data)
        '-ac', '1', // Number of audio channels (adjust if needed)
        '-i', dire ?? "", // Input file
        '-c:a', 'opus', // Codec: Opus
        '-b:a', '64k', // Bitrate (adjust as needed)
        '-strict', '-2',
        outFile, // Output file
      ];

      final result = await FFmpegKit.executeWithArgumentsAsync(command);

      if (await result.getReturnCode() != ReturnCode(0)) {
        final fuckingErrors = await result.getLogs();

        for (var fuck in fuckingErrors) {
          //print(fuck.getMessage());
        }
      }

      File file = File(outFile ?? "");

      Uint8List audioData = await file.readAsBytes();

      print("audio data output is ${audioData.length}");

      sendMessage(audioData);

      File(dir).deleteSync();

      File(dir).createSync();
      recorder.start(
          const RecordConfig(
              encoder: AudioEncoder.pcm16bits,
              sampleRate: 16000, // Ensure this matches
              numChannels: 1),
          path: dir);

      return;
    });
  }

  String get getReconizedWords => reconizedWords;
}
