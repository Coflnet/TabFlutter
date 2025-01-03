import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';

class ParamOptionsHeader extends StatelessWidget {
  final VoidCallback addNewParam;
  const ParamOptionsHeader({super.key, required this.addNewParam});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(translate("columns"),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        IconButton(
            padding: EdgeInsets.zero,
            onPressed: addNewParam,
            icon: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: HexColor("23263E"),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(
                Icons.add,
                size: 30,
                color: Colors.grey.shade400,
              ),
            ))
      ],
    );
  }
}
