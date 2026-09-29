import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/pages/settings/export/copy_as_tsv.dart';
import 'package:table_entry/pages/settings/export/exportAsCsv.dart';

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExportAsCsv(openPopup: widget.exportPopup),
            const SizedBox(width: 16),
            const CopyAsTsv(),
          ],
        )
      ],
    );
  }
}
