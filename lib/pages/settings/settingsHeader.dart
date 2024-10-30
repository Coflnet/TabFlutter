import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/pages/settings/settingHeaderLang.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 55),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              translate("settingsHeader"),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 30),
            ),
            const SettingHeaderLang()
          ],
        ),
      ),
    );
  }
}
