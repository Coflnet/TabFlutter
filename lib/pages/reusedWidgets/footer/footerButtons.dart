import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/pages/settings/settingsMain.dart';

class FooterButtons extends StatelessWidget {
  final IconData pickedIcon;
  final String text;
  final int selectedPageNum;
  final int wantedPageNum;
  final Widget scene;
  const FooterButtons(
      {super.key,
      required this.pickedIcon,
      required this.text,
      required this.selectedPageNum,
      required this.wantedPageNum,
      required this.scene});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            style: IconButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => {changeScene(scene, context)},
            icon: Icon(
              pickedIcon,
              size: 35,
              color: selectedPageNum == wantedPageNum
                  ? HexColor("#8332AC")
                  : Colors.white30,
            )),
        Transform.translate(
          offset: const Offset(0, -6),
          child: Text(
            text,
            style: TextStyle(
                fontSize: 14,
                color: selectedPageNum == wantedPageNum
                    ? HexColor("#8332AC")
                    : Colors.white30,
                fontWeight: FontWeight.w700),
          ),
        )
      ],
    );
  }

  void changeScene(Widget changeToPage, context) {
    Haptics.vibrate(HapticsType.medium);
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => changeToPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
          transitionDuration: const Duration(milliseconds: 0),
        ));
  }
}
