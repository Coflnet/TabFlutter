import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
        SizedBox(height: 6),
        ExportAsCsv()
      ],
    );
  }
}
