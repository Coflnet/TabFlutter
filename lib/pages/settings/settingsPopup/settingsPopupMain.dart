import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsMain.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsPopup.dart';

class SettingsPopupMain extends StatefulWidget {
  final bool isShowing;
  final VoidCallback closePopup;
  const SettingsPopupMain(
      {super.key, required this.isShowing, required this.closePopup});

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
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ColumnSettingsPopup(
                  isShowing: widget.isShowing,
                  closePopup: widget.closePopup,
                ),
                IconButton(
                    onPressed: () {
                      widget.closePopup();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 37,
                      color: Colors.grey.shade400,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
