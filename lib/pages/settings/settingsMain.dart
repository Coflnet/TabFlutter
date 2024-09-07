import 'package:flutter/material.dart';
import 'package:table_entry/pages/reusedWidgets/background.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footer.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsMain.dart';
import 'package:table_entry/pages/settings/settingsHeader.dart';
import 'package:table_entry/pages/settings/settingsPopup/settingsPopupMain.dart';

class SettingsMain extends StatelessWidget {
  const SettingsMain({super.key});

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
              child: const Column(
                children: <Widget>[
                  SettingsHeader(),
                  SizedBox(height: 20),
                  ColumnSettingsMain(),
                ],
              ),
            ),
            const Footer(),
            SettingsPopupMain()
          ],
        ),
      ),
    );
  }
}
