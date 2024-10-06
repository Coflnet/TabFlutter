import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';

class NewListParamHeader extends StatelessWidget {
  final VoidCallback addCount;
  const NewListParamHeader({super.key, required this.addCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            translate("listOptions"),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
          ),
          IconButton(
              padding: EdgeInsets.zero,
              onPressed: addCount,
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
      ),
    );
  }
}
