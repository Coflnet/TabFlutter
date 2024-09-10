import 'package:flutter/material.dart';
import 'package:table_entry/pages/reusedWidgets/background.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footer.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsMain.dart';
import 'package:table_entry/pages/settings/settingsHeader.dart';
import 'package:table_entry/pages/settings/settingsPopup/settingsPopupMain.dart';

class SettingsMain extends StatefulWidget {
  const SettingsMain({Key? key}) : super(key: key);

  @override
  _SettingsMainState createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  bool popupVisible = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "WorkSans"),
      home: Scaffold(
        body: Stack(
          children: [
            const Background(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: <Widget>[
                  const SettingsHeader(),
                  const SizedBox(height: 20),
                  ColumnSettingsMain(popup: popup),
                ],
              ),
            ),
            const Footer(),
            Visibility(
                visible: popupVisible,
                child: SettingsPopupMain(
                    isShowing: popupVisible, closePopup: popup))
          ],
        ),
      ),
    );
  }

  void popup() {
    setState(() {
      popupVisible = !popupVisible;
    });
  }
}
