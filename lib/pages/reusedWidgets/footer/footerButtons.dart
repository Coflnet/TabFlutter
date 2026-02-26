import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footerGlobal.dart';
import 'package:table_entry/pages/settings/settingsMain.dart';

class FooterButtons extends StatelessWidget {
  final List<List<dynamic>> pickedIcon;
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
    return TextButton(
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      onPressed: () => {changeScene(scene, context)},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          HugeIcon(
            icon: pickedIcon,
            size: 35,
            color: selectedPageNum == wantedPageNum
                ? HexColor("#8332AC")
                : Colors.white30,
          ),
          Transform.translate(
            offset: const Offset(0, -3),
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
      ),
    );
  }

  void changeScene(Widget changeToPage, context) {
    FooterGlobal().setSelectedPage = wantedPageNum;
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
