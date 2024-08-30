import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

class CurrentStatusVisulization extends StatefulWidget {
  const CurrentStatusVisulization({Key? key}) : super(key: key);

  @override
  _CurrentStatusVisulizationState createState() =>
      _CurrentStatusVisulizationState();
}

class _CurrentStatusVisulizationState extends State<CurrentStatusVisulization> {
  Stream<List<int>>? micStream;
  double soundLevel = 0;
  late final RecorderController controller;
  List inputNumbers = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    controller = RecorderController();
    listenToAudio();
    timer = Timer.periodic(Duration(milliseconds: 130), addNewInputNum);
  }

  void listenToAudio() {
    NoiseMeter().noise.listen((NoiseReading noise) {
      soundLevel = noise.meanDecibel.round() - 0.0;
      print(soundLevel);
    }, onError: (Object error) {
      print(error);
    });
  }

  void addNewInputNum(t) {
    setState(() {
      if (soundLevel > 70.0) {
        inputNumbers.insert(0, soundLevel / 18);
      } else {
        inputNumbers.insert(0, soundLevel / 20);
      }

      if (inputNumbers.length == 20) {
        inputNumbers.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(top: 50),
        height: 300,
        width: 300,
        color: Colors.white,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: inputNumbers.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: (inputNumbers[index] *
                          inputNumbers[index] *
                          inputNumbers[index]) /
                      2,
                  decoration: BoxDecoration(color: Colors.blue),
                  width: 2,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
