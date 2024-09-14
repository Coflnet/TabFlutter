import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/pages/main/recentLog/recentLogItem.dart';

class RecentLogColumn extends StatefulWidget {
  final List<col> recentLog;
  const RecentLogColumn({super.key, required this.recentLog});

  @override
  _RecentLogColumnState createState() => _RecentLogColumnState();
}

class _RecentLogColumnState extends State<RecentLogColumn> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
            itemCount: recentLog.length,
            itemBuilder: (context, index) => RecentLogItem(
                name: widget.recentLog[index].name,
                values: widget.recentLog[index].params,
                index: index,
                settings: false,
                buttonClicked: buttonClicked)));
  }

  void buttonClicked(col whichCollumn) {}
}
