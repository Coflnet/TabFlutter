import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';

class ColumnSettingsHeader extends StatelessWidget {
  const ColumnSettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          "Columns",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 23),
        ),
        TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4)),
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: HexColor("1E202E"),
                borderRadius: BorderRadius.circular(60),
              ),
              child: HugeIcon(
                icon: Icons.add,
                color: Colors.grey.shade200,
                size: 35,
              ),
            ))
      ],
    );
  }
}
