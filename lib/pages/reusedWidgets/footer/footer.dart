import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:table_entry/main.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footerButtons.dart';
import 'package:table_entry/pages/settings/settingsMain.dart';

class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(color: HexColor("1D1E2B")),
        height: 77,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FooterButtons(
                scene: const Main(),
                pickedIcon: HugeIcons.strokeRoundedHome03,
                text: "Home",
                selectedPageNum: selectedPage,
                wantedPageNum: 0),
            FooterButtons(
                scene: const Main(),
                pickedIcon: HugeIcons.strokeRoundedAnalysisTextLink,
                text: "Stats",
                selectedPageNum: selectedPage,
                wantedPageNum: 1),
            FooterButtons(
                scene: const SettingsMain(),
                pickedIcon: HugeIcons.strokeRoundedSettings01,
                text: "Settings",
                selectedPageNum: selectedPage,
                wantedPageNum: 1),
          ],
        ),
      ),
    );
  }
}
