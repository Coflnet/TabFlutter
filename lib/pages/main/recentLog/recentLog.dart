import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/pages/main/recentLog/recentLogColumn.dart';

class UpdateRecentLog extends ChangeNotifier {
  late _RecentLogState lbState;

  void setPageState(_RecentLogState state) {
    lbState = state;
  }

  void recentLogUpdate() {
    lbState.recentLogUpdate();
  }
}

class RecentLog extends StatefulWidget {
  const RecentLog({Key? key}) : super(key: key);

  @override
  _RecentLogState createState() => _RecentLogState();
}

class _RecentLogState extends State<RecentLog> {
  List<col> recentLogItems = [];
  void recentLogUpdate() {
    setState(() {
      recentLogItems = RecentLogHandler().getRecentLog;
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UpdateRecentLog>(context, listen: false).setPageState(this);

    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Recent Log",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 23),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Expanded(child: RecentLogColumn(recentLog: recentLogItems)),
        const SizedBox(height: 77)
      ],
    );
  }
}
