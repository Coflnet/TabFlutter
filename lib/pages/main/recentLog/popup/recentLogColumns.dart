import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsNotifer.dart';

class RecentLogColumns extends StatefulWidget {
  const RecentLogColumns({Key? key}) : super(key: key);

  @override
  _RecentLogColumnsState createState() => _RecentLogColumnsState();
}

class _RecentLogColumnsState extends State<RecentLogColumns> {
  @override
  Widget build(BuildContext context) {
    return Consumer<recnetLogPopupNotifer>(builder: (context, value, child) {
      interact();
      return const Column(
        children: <Widget>[
          Text(
            "Columns",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          )
        ],
      );
    });
  }

  void interact() {}
}
