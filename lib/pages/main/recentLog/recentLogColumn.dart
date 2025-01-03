import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spables/globals/columns/editColumnsClasses.dart';
import 'package:spables/globals/columns/editingColumns.dart';
import 'package:spables/globals/recentLogRequest/recentLogHandler.dart';
import 'package:spables/pages/main/recentLog/recentLogItem.dart';

class RecentLogColumn extends StatefulWidget {
  final List<col> recentLog;
  final VoidCallback changeVis;
  const RecentLogColumn(
      {super.key, required this.recentLog, required this.changeVis});

  @override
  _RecentLogColumnState createState() => _RecentLogColumnState();
}

class _RecentLogColumnState extends State<RecentLogColumn> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            itemCount: widget.recentLog.isEmpty ? 0 : widget.recentLog.length,
            itemBuilder: (context, index) {
              if (recentLog.isEmpty) {
                return Container();
              } else {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: RecentLogItem(
                      name: (widget.recentLog.isEmpty)
                          ? ""
                          : widget.recentLog[length(index)].name,
                      values: (widget.recentLog.isEmpty)
                          ? []
                          : widget.recentLog[length(index)].params,
                      index: index,
                      settings: true,
                      buttonClicked: buttonClicked),
                );
              }
            }));
  }

  void buttonClicked(int index) {
    EditingColumns().setEditingCol = RecentLogHandler()
        .getDisplayedLog[(widget.recentLog.length - 1) - index]
        .copy();
    EditingColumns().setEditingIndex = ((widget.recentLog.length - 1) - index);
    widget.changeVis();
  }

  int length(int index) {
    return (widget.recentLog.isEmpty)
        ? index
        : (widget.recentLog.length - 1) - index;
  }
}
