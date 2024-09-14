import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/pages/main/selectedColumn/selectColumnSelector.dart';

class SelectCollumnMain extends StatefulWidget {
  const SelectCollumnMain({Key? key}) : super(key: key);

  @override
  _SelectCollumnMainState createState() => _SelectCollumnMainState();
}

class _SelectCollumnMainState extends State<SelectCollumnMain> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 150,
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: const SelectColumnSelector()),
        ),
        SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 13,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    HexColor("12131d"),
                    HexColor("12131d").withAlpha(0),
                  ],
                )),
              ),
              Container(
                height: 13,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    HexColor("12131d"),
                    HexColor("12131d").withAlpha(0),
                  ],
                )),
              )
            ],
          ),
        )
      ],
    );
  }
}
