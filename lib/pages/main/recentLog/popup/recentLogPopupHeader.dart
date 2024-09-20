import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsNotifer.dart';

class RecentLogPopupHeader extends StatefulWidget {
  const RecentLogPopupHeader({Key? key}) : super(key: key);

  @override
  _RecentLogPopupHeaderState createState() => _RecentLogPopupHeaderState();
}

class _RecentLogPopupHeaderState extends State<RecentLogPopupHeader> {
  String name = EditingColumns().getEditingCol.name;

  @override
  Widget build(BuildContext context) {
    return Consumer<recnetLogPopupNotifer>(builder: (context, value, child) {
      interact();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 23),
          )
        ],
      );
    });
  }

  void interact() {
    setState(() {
      name = EditingColumns().getEditingCol.name;
    });
  }
}
