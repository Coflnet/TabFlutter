import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:spables/pages/settings/export/exportAsCsv.dart';

class SettingExportMain extends StatefulWidget {
  final Function(int) exportPopup;
  const SettingExportMain({super.key, required this.exportPopup});

  @override
  _SettingExportMainState createState() => _SettingExportMainState();
}

class _SettingExportMainState extends State<SettingExportMain> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              translate("export"),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ExportAsCsv(openPopup: widget.exportPopup)
      ],
    );
  }
}
