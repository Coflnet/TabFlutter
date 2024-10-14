import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/speach/voiceDetection/startStopDetectionFirstTime.dart';
import 'package:table_entry/speach/voiceDetection/startStopDetectionNoAudio.dart';

class StartStopDetectionRunning extends StatefulWidget {
  final bool run;
  final VoidCallback startStop;
  const StartStopDetectionRunning(
      {super.key, required this.startStop, required this.run});

  @override
  _StartStopDetectionRunningState createState() =>
      _StartStopDetectionRunningState();
}

class _StartStopDetectionRunningState extends State<StartStopDetectionRunning> {
  late CustomPopupMenuController controller;
  int selectedType = 2;

  @override
  void initState() {
    super.initState();
    controller = CustomPopupMenuController();
    print("called");
    waitCall();
  }

  void waitCall() async {
    await Future.delayed(Duration(milliseconds: 300));
    if (widget.run) {
      setState(() {
        selectedType = 1;
      });
      controller.showMenu();
      return;
    }
    if (!SaveColumn().getUsedBefore) {
      setState(() {
        selectedType = 2;
        controller.showMenu();
      });
      SaveColumn().setUsedBefore = true;
      SaveColumn().saveFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      verticalMargin: -2,
      arrowSize: 20,
      controller: controller,
      pressType: PressType.longPress,
      menuBuilder: () {
        switch (selectedType) {
          case 1:
            return const StartStopDetectionNoAudio();
          case 2:
            return const StartStopDetectionFirstTime();
          default:
            return Container();
        }
      },
      menuOnChange: (bool state) => {
        if (!controller.menuIsShowing)
          {
            setState(() {
              selectedType = 0;
            })
          }
      },
      child: TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: widget.startStop,
          child: Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: HexColor("#8332AC"),
                borderRadius: BorderRadius.circular(90)),
            child: const Icon(
              Icons.stop,
              color: Colors.white,
              size: 45,
            ),
          )),
    );
  }
}
