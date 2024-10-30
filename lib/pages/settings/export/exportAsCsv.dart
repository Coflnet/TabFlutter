import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_entry/globals/convertCSV.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';

class ExportAsCsv extends StatelessWidget {
  final Function(int) openPopup;
  const ExportAsCsv({super.key, required this.openPopup});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4)),
            onPressed: handleCSV,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: HexColor("1E202E"),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Column(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedFileExport,
                    color: Colors.grey.shade300,
                    size: 31,
                  ),
                  const SizedBox(width: 55),
                  Text(
                    "csv",
                    style: TextStyle(
                        color: Colors.grey.shade100,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            )),
        const SizedBox(height: 5),
      ],
    );
  }

  void handleCSV() async {
    openPopup(1);
    return;
    String csv = ConvertCsv().convertCsv(RecentLogHandler().getRecentLog);
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDir.path}/exportCSVTEMP.json";
    File file = File(filePath);
    file.createSync();
    final result = await Share.shareXFiles(
        [XFile.fromData(utf8.encode(csv), mimeType: "csv", name: "TabData")],
        fileNameOverrides: ["TabData"], text: "Data as csv");
    if (result.status == ShareResultStatus.success) {
      print("yay");
    }
  }
}
