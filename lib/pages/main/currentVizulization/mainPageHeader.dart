import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hugeicons/hugeicons.dart';

class MainPageHeader extends StatelessWidget {
  const MainPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Home",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 30),
        ),
        TextButton(
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: HexColor("1E202E"),
                borderRadius: BorderRadius.circular(60),
              ),
              child: HugeIcon(
                icon: Icons.more_vert,
                color: Colors.grey.shade200,
                size: 40,
              ),
            ))
      ],
    );
  }
}
