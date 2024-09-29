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
  final VoidCallback changeVis;
  const RecentLog({super.key, required this.changeVis});

  @override
  _RecentLogState createState() => _RecentLogState();
}

class _RecentLogState extends State<RecentLog> {
  List<col> recentLogItems = [];
  void recentLogUpdate() {
    setState(() {
      recentLogItems = RecentLogHandler().getDisplayedLog;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      recentLogItems = RecentLogHandler().getDisplayedLog;
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UpdateRecentLog>(context, listen: false).setPageState(this);

    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              "Recent Log",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 23),
            ),
            TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => {
                      RecentLogHandler().clear(),
                      Provider.of<UpdateRecentLog>(context, listen: false)
                          .recentLogUpdate()
                    },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HexColor("1E202E"),
                    borderRadius: BorderRadius.circular(120),
                  ),
                  child: Icon(
                    size: 27,
                    HugeIcons.strokeRoundedDelete04,
                    color: Colors.grey.shade200,
                  ),
                ))
          ],
        ),
        const SizedBox(height: 7),
        Expanded(
            child: RecentLogColumn(
                recentLog: recentLogItems, changeVis: widget.changeVis)),
      ],
    );
  }
}
