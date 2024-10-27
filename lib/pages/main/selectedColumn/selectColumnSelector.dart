import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/pages/main/recentLog/recentLogItem.dart';

class SelectColumnSelector extends StatefulWidget {
  const SelectColumnSelector({super.key});

  @override
  _SelectColumnSelectorState createState() => _SelectColumnSelectorState();
}

class _SelectColumnSelectorState extends State<SelectColumnSelector> {
  List columns = SaveColumn().getColumns;
  int _currentIndex = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(SaveColumn().getSelcColumn * 100,
          curve: Curves.easeInOutQuart,
          duration: const Duration(milliseconds: 420));
    });

    loadColumns();
  }

  void loadColumns() async {
    setState(() {
      columns = SaveColumn().getColumns;
    });
    RecentLogHandler().setCurrentSelected = columns[0];
  }

  void _onScroll() {
    double itemHeight = 70.0;
    int newIndex = (_scrollController.offset / itemHeight).round();

    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
      _onSelectedIndexChanged(newIndex);
    }
  }

  void _onSelectedIndexChanged(int index) {
    SaveColumn().setSelcColumn = index;
    SaveColumn().saveFile();
    RecentLogHandler().setCurrentSelected = columns[index];
  }

  @override
  Widget build(BuildContext context) {
    return ScrollSnapList(
        listController: _scrollController,
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
        itemSize: 90,
        onItemFocus: (int num) {
          SaveColumn().setSelcColumn = num;
          SaveColumn().saveFile();
          RecentLogHandler().setCurrentSelected = columns[num];
        });
  }

  double _smoothStep(double x) {
    return x * x * (3 - 2 * x);
  }

  double _getItemPosition(int index) {
    if (!_scrollController.hasClients) return 0.0;
    double itemHeight = 100.0;
    double scrollOffset = _scrollController.offset;
    double itemPosition =
        (index * itemHeight - scrollOffset).abs() / itemHeight;

    return itemPosition;
  }
}
