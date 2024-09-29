import 'package:flutter/material.dart';
import 'package:table_entry/pages/main/currentVizulization/currentStateHeader.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';
import 'package:table_entry/pages/main/selectedColumn/selectCollumnMain.dart';

class RecentLogSelectHolder extends StatelessWidget {
  final VoidCallback closePopup;
  const RecentLogSelectHolder({super.key, required this.closePopup});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          const CurrentStateHeader(),
          const SelectCollumnMain(),
          Expanded(
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: RecentLog(
                  changeVis: closePopup,
                )),
          )
        ],
      ),
    );
  }
}
