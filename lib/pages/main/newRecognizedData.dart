import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class NewRecognizedData extends StatelessWidget {
  final List data;
  const NewRecognizedData({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: HexColor("303154"), borderRadius: BorderRadius.circular(8)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "🐝Hive: 1",
          ),
          Text("🍯 Amount: 3 kilos")
        ],
      ),
    );
  }
}
