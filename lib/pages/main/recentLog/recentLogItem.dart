import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/pages/main/recentLog/recentLogMoreInfo.dart';
import 'package:table_entry/pages/main/recentLog/recentLogName.dart';

class RecentLogItem extends StatelessWidget {
  const RecentLogItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          margin: const EdgeInsets.only(bottom: 17),
          decoration: BoxDecoration(
              color: HexColor("1D1E2B"),
              borderRadius: BorderRadius.circular(16)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RecentLogName(name: "Hive 1"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Honey",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "10kg",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  )
                ],
              ),
              const SizedBox(width: 30)
            ],
          ),
        ),
        const RecentLogMoreInfo()
      ],
    );
  }
}
