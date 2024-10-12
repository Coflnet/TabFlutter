import 'package:flutter/material.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';
import 'package:table_entry/pages/main/recentLog/recentLogItem.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsHeader.dart';

class ColumnSettingsMain extends StatefulWidget {
  final VoidCallback popup;
  const ColumnSettingsMain({super.key, required this.popup});

  @override
  _ColumnSettingsMainState createState() => _ColumnSettingsMainState();
}

class _ColumnSettingsMainState extends State<ColumnSettingsMain> {
  List<col> createdColumns = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      createdColumns = SaveColumn().getColumns;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ColumnSettingsHeader(addNewColl: addNewCollumn),
        const SizedBox(height: 9),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: createdColumns.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 17),
                  child: RecentLogItem(
                    name: createdColumns[index].name,
                    values: createdColumns[index].params,
                    settings: true,
                    index: index,
                    buttonClicked: editCollumnPressed,
                  ),
                );
              }),
        )
      ],
    );
  }

  void addNewCollumn() {
    setState(() {
      createdColumns
          .add(EditingColumns().createNewCol("", createdColumns.length));
    });
    widget.popup();
  }

  void editCollumnPressed(int index) {
    EditingColumns().setEditingCol = SaveColumn().getColumns[index].copy();
    widget.popup();
  }
}
