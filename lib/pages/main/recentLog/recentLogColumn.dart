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
  void initState() {
    super.initState();
    print(widget.recentLog.length);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            itemCount: recentLog.length,
            itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: (recentLog.length == 0)
                      ? Container()
                      : RecentLogItem(
                          name: widget
                              .recentLog[(widget.recentLog.length - 1) - index]
                              .name,
                          values: widget
                              .recentLog[(widget.recentLog.length - 1) - index]
                              .params,
                          index: index,
                          settings: false,
                          buttonClicked: buttonClicked),
                )));
  }

  void buttonClicked(col whichCollumn) {}
}
