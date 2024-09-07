import 'package:flutter/material.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';
import 'package:table_entry/pages/main/recentLog/recentLogItem.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsHeader.dart';

class ColumnSettingsMain extends StatelessWidget {
  const ColumnSettingsMain({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        ColumnSettingsHeader(),
        SizedBox(height: 9),
        RecentLogItem(),
        RecentLogItem()
      ],
    );
  }
}
