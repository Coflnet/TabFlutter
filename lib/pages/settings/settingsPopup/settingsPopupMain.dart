import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsMain.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsPopup.dart';

class SettingsPopupMain extends StatefulWidget {
  const SettingsPopupMain({Key? key}) : super(key: key);

  @override
  _SettingsPopupMainState createState() => _SettingsPopupMainState();
}

class _SettingsPopupMainState extends State<SettingsPopupMain> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black38,
          child: const Center(
            child: ColumnSettingsPopup(),
          ),
        ),
      ),
    );
  }
}
