import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:table_entry/pages/main/recentLog/recentLogColumn.dart';

class RecentLog extends StatefulWidget {
  const RecentLog({Key? key}) : super(key: key);

  @override
  _RecentLogState createState() => _RecentLogState();
}

class _RecentLogState extends State<RecentLog> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        SizedBox(height: 8),
        Row(
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
        SizedBox(height: 7),
        Expanded(child: RecentLogColumn())
      ],
    );
  }
}
