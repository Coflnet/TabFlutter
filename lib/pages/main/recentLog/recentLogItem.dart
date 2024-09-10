import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/pages/main/recentLog/recentLogItemParam.dart';
import 'package:table_entry/pages/main/recentLog/recentLogMoreInfo.dart';
import 'package:table_entry/pages/main/recentLog/recentLogName.dart';

class RecentLogItem extends StatefulWidget {
  final String name;
  final List<param> values;
  const RecentLogItem({super.key, required this.name, required this.values});

  @override
  _RecentLogItemState createState() => _RecentLogItemState();
}

class _RecentLogItemState extends State<RecentLogItem> {
  @override
  void initState() {
    super.initState();
    print(widget.values[0].name);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          margin: const EdgeInsets.only(bottom: 17),
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
              const SizedBox(width: 30)
            ],
          ),
        ),
        const RecentLogMoreInfo()
      ],
    );
  }
}
