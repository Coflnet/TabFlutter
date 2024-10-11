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
  late ScrollController controller;

  void initState() {
    super.initState();
    loadColumns();
    controller = ScrollController(
        initialScrollOffset: SaveColumn().getSelcColumn.toDouble());
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
    return ScrollSnapList(
        listController: controller,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return (index == columns.length)
              ? Container(height: 50)
              : RecentLogItem(
                  name: columns[index].name,
                  values: columns[index].params,
                  settings: false,
                  index: index,
                  buttonClicked: (i) {},
                );
        },
        dynamicItemSize: true,
        itemCount: columns.length + 1,
        itemSize: 100,
        onItemFocus: (int num) {
          SaveColumn().setSelcColumn = num;
          RecentLogHandler().setCurrentSelected = columns[num];
        });
  }
}
