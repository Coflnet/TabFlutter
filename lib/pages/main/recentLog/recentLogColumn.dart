import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/pages/main/recentLog/recentLogItem.dart';

class RecentLogColumn extends StatefulWidget {
  const RecentLogColumn({Key? key}) : super(key: key);

  @override
  _RecentLogColumnState createState() => _RecentLogColumnState();
}

class _RecentLogColumnState extends State<RecentLogColumn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[RecentLogItem(), RecentLogItem(), RecentLogItem()],
      ),
    );
  }
}
