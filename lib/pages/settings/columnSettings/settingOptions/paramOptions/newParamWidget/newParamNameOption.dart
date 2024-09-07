import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class NewParamNameOption extends StatefulWidget {
  const NewParamNameOption({Key? key}) : super(key: key);

  @override
  _NewParamNameOptionState createState() => _NewParamNameOptionState();
}

class _NewParamNameOptionState extends State<NewParamNameOption> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          const Text(
            "Name",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(6, 6, 0, 6),
            margin: const EdgeInsets.fromLTRB(8, 0, 12, 0),
            decoration: BoxDecoration(
                color: HexColor("2A2D54"),
                borderRadius: BorderRadius.circular(8)),
            child: const TextField(
              decoration: InputDecoration.collapsed(
                hintStyle: const TextStyle(color: Colors.white30),
                hintText: "Set name",
              ),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }
}
