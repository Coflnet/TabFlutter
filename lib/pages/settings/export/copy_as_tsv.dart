import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/copy_entries.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';

/// Copies all recorded lines for pasting into Excel or LibreOffice.
class CopyAsTsv extends StatelessWidget {
  const CopyAsTsv({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4)),
            onPressed: () =>
                copyEntriesToClipboard(RecentLogHandler().getRecentLog),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: HexColor("1E202E"),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Column(
                children: [
                  Icon(Icons.copy_rounded,
                      color: Colors.grey.shade300, size: 31),
                  const SizedBox(width: 55),
                  Text(
                    translate("copy"),
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
}
