import 'package:flutter/material.dart';
import 'package:spables/globals/columns/editColumnsClasses.dart';
import 'package:spables/globals/columns/editingColumns.dart';
import 'package:spables/globals/columns/saveColumn.dart';
import 'package:spables/pages/main/recentLog/recentLogItem.dart';
import 'package:spables/pages/settings/columnSettings/columnSettingsHeader.dart';

class ColumnSettingsMain extends StatefulWidget {
  final Function(int) popup;
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
              physics: const NeverScrollableScrollPhysics(),
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
        ),
        Container(height: 75)
      ],
    );
  }

  void addNewCollumn() {
    setState(() {
      createdColumns
          .add(EditingColumns().createNewCol("", createdColumns.length));
    });
    widget.popup(0);
  }

  void editCollumnPressed(int index) {
    EditingColumns().setEditingCol = SaveColumn().getColumns[index].copy();
    widget.popup(0);
  }
}
