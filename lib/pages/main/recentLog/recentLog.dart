import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
  List<col> recentLogItems = RecentLogHandler().getDisplayedLog;
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
            Text(
              translate("recentLog"),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 23),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Text(
                    "85/100",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 7),
        Expanded(
            child: RecentLogColumn(
                recentLog: recentLogItems, changeVis: widget.changeVis)),
        const SizedBox(height: 75)
      ],
    );
  }
}

Color getTweenColor(double value) {
  value = value.clamp(0, 100);
  double normalizedValue = value / 100;
  return Color.lerp(Colors.red[100], Colors.white, normalizedValue)!;
}
