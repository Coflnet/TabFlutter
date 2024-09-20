import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:table_entry/pages/settings/export/exportAsCsv.dart';

class SettingExportMain extends StatefulWidget {
  const SettingExportMain({Key? key}) : super(key: key);

  @override
  _SettingExportMainState createState() => _SettingExportMainState();
}

class _SettingExportMainState extends State<SettingExportMain> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Export",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 6),
        ExportAsCsv()
      ],
    );
  }
}
