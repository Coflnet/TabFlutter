import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/pages/main/recentLog/recentLogItemParam.dart';
import 'package:table_entry/pages/main/recentLog/recentLogMoreInfo.dart';
import 'package:table_entry/pages/main/recentLog/recentLogName.dart';

class RecentLogItem extends StatefulWidget {
  final String name;
  final List<param> values;
  final int index;
  final bool settings;
  final Function(col) buttonClicked;
  const RecentLogItem(
      {super.key,
      required this.name,
      required this.values,
      required this.index,
      required this.settings,
      required this.buttonClicked});

  @override
  _RecentLogItemState createState() => _RecentLogItemState();
}

class _RecentLogItemState extends State<RecentLogItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: (widget.settings) ? clickedSettings : () {},
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            margin: const EdgeInsets.only(bottom: 0),
            decoration: BoxDecoration(
                color: HexColor("1D1E2B"),
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RecentLogName(name: widget.name),
                RecentLogItemParam(
                    values: [widget.values[0].name, widget.values[0]]),
                RecentLogItemParam(
                    values: (widget.values.length == 2)
                        ? [widget.values[1].name, widget.values[1]]
                        : []),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
        const RecentLogMoreInfo()
      ],
    );
  }

  void clickedSettings() {
    widget.buttonClicked(SaveColumn().getColumns[widget.index]);
  }
}
