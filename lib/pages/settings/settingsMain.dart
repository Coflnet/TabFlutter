import 'package:flutter/material.dart';
import 'package:spables/pages/reusedWidgets/background.dart';
import 'package:spables/pages/reusedWidgets/footer/footer.dart';
import 'package:spables/pages/settings/columnSettings/columnSettingsMain.dart';
import 'package:spables/pages/settings/export/settingExportMain.dart';
import 'package:spables/pages/settings/settingsHeader.dart';
import 'package:spables/pages/settings/settingsPopup/settingsPopupMain.dart';

class SettingsMain extends StatefulWidget {
  const SettingsMain({super.key});

  @override
  _SettingsMainState createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  bool popupVisible = false;
  int popupSelected = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SettingsHeader(),
                  const SizedBox(height: 35),
                  SettingExportMain(exportPopup: popup),
                  const SizedBox(height: 20),
                  ColumnSettingsMain(popup: popup),
                ],
              ),
            ),
          ),
          const Footer(),
          Visibility(
              visible: popupVisible,
              child: SettingsPopupMain(
                  isShowing: popupVisible,
                  closePopup: closePopup,
                  selectedPopup: popupSelected))
        ],
      ),
    );
  }

  void closePopup() {
    setState(() {
      popupVisible = false;
    });
  }

  void popup(int select) {
    setState(() {
      popupSelected = select;
      popupVisible = !popupVisible;
    });
  }
}
