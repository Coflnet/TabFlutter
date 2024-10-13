import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/pages/main/recentLog/recentLogItem.dart';

class SelectColumnSelector extends StatefulWidget {
  const SelectColumnSelector({Key? key}) : super(key: key);

  @override
  _SelectColumnSelectorState createState() => _SelectColumnSelectorState();
}

class _SelectColumnSelectorState extends State<SelectColumnSelector> {
  List columns = SaveColumn().getColumns;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadColumns();
  }

  void loadColumns() async {
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      columns = SaveColumn().getColumns;
    });
    RecentLogHandler().setCurrentSelected = columns[0];
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (scrollNotification) {
        setState(() {}); // Trigger rebuild on scroll
        return true;
      },
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
          controller: _scrollController,
          itemBuilder: (context, index) {
            double itemPosition = _getItemPosition(index);

            double scale = lerpDouble(0.9, 1.0, _smoothStep(1 - itemPosition))!;

            return Transform.scale(
                scale: scale,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: RecentLogItem(
                    name: columns[index].name,
                    values: columns[index].params,
                    settings: false,
                    index: index,
                    buttonClicked: (i) {},
                  ),
                ));
          },
          physics: BouncingScrollPhysics(parent: PageScrollPhysics()),
          itemExtent: 100,
          itemCount: columns.length,
        ),
      ),
    );
  }

  double _smoothStep(double x) {
    return x * x * (3 - 2 * x);
  }

  double _getItemPosition(int index) {
    if (!_scrollController.hasClients) return 0.0;
    double itemHeight = 200.0;
    double scrollOffset = _scrollController.offset;
    double itemPosition =
        (index * itemHeight - scrollOffset).abs() / itemHeight;

    return itemPosition;
  }
}
