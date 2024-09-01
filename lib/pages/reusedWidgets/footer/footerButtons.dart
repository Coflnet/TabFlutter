import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class FooterButtons extends StatelessWidget {
  final IconData pickedIcon;
  final String text;
  final int selectedPageNum;
  final int wantedPageNum;
  const FooterButtons(
      {super.key,
      required this.pickedIcon,
      required this.text,
      required this.selectedPageNum,
      required this.wantedPageNum});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            style: IconButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () {},
            icon: Icon(
              pickedIcon,
              size: 35,
              color: selectedPageNum == wantedPageNum
                  ? HexColor("#8332AC")
                  : Colors.white30,
            )),
        Transform.translate(
          offset: const Offset(0, -6),
          child: Text(
            text,
            style: TextStyle(
                fontSize: 14,
                color: selectedPageNum == wantedPageNum
                    ? HexColor("#8332AC")
                    : Colors.white30,
                fontWeight: FontWeight.w700),
          ),
        )
      ],
    );
  }
}
