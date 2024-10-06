import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';

class ColumnSettingsHeader extends StatelessWidget {
  final VoidCallback addNewColl;
  const ColumnSettingsHeader({super.key, required this.addNewColl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          translate("columnSettingHeader"),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 23),
        ),
        TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4)),
            onPressed: addNewColl,
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
