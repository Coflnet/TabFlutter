import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [HexColor("12131d"), HexColor("12131d")],
    )));
  }
}
