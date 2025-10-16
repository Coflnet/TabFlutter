import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:table_entry/pages/main/currentVizulization/currentStateHeader.dart';
import 'package:table_entry/pages/main/currentVizulization/mainPageHeader.dart';
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
  List inputNumbers = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    return;
    //controller = RecorderController();
    listenToAudio();
    timer = Timer.periodic(const Duration(milliseconds: 130), addNewInputNum);
  }

  @override
  void dispose() {
    super.dispose();
    //controller.dispose();
  }

  void listenToAudio() {
    NoiseMeter().noise.listen((NoiseReading noise) {
      soundLevel = noise.meanDecibel.round() - 0.0;
    }, onError: (Object error) {
      print(error);
    });
  }

  void addNewInputNum(t) {
    setState(() {
      if (soundLevel > 65.0) {
        inputNumbers.insert(0, soundLevel / 17);
      } else {
        inputNumbers.insert(0, soundLevel / 20);
      }
      if (inputNumbers.length == 28) {
        inputNumbers.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const MainPageHeader(),
            const SizedBox(height: 20),
            const CurrentStateHeader(),
            Container(
              height: 140,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                  color: HexColor("1D1E2B"),
                  borderRadius: BorderRadius.circular(16)),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 9),
                    child: Text(
                      "Stand-by",
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListView.builder(
                    reverse: true,
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
                                1.2,
                            decoration: BoxDecoration(
                                color: HexColor(
                                  "#8332AC",
                                ).withAlpha(100),
                                borderRadius: BorderRadius.circular(20)),
                            width: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
