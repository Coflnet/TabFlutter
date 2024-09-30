import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class StartStopDetectionRunning extends StatelessWidget {
  final VoidCallback startStop;
  const StartStopDetectionRunning({super.key, required this.startStop});

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      pressType: PressType.singleClick,
      menuBuilder: () => TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: startStop,
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
