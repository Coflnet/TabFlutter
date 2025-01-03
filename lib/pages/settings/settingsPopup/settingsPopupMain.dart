import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spables/pages/settings/columnSettings/collumnSettingContainer.dart';
import 'package:spables/pages/settings/csvExport/csvExportPopupMain.dart';

class SettingsPopupMain extends StatefulWidget {
  final int selectedPopup;
  final bool isShowing;
  final VoidCallback closePopup;
  const SettingsPopupMain(
      {super.key,
      required this.isShowing,
      required this.closePopup,
      required this.selectedPopup});

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
          child: Center(
              child: (widget.selectedPopup == 0)
                  ? Collumnsettingcontainer(
                      isShowing: widget.isShowing,
                      closePopup: widget.closePopup)
                  : CsvExportPopupMain(closePopup: widget.closePopup)),
        ),
      ),
    );
  }
}
