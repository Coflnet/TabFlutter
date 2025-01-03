import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';

class NewListParam extends StatefulWidget {
  final int itemCount;
  final String name;
  final Function(int, String) updateParamName;
  const NewListParam(
      {super.key,
      required this.updateParamName,
      required this.itemCount,
      required this.name});

  @override
  _NewListParamState createState() => _NewListParamState();
}

class _NewListParamState extends State<NewListParam> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(31, 215, 212, 255), width: 2),
              borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration.collapsed(
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
              hintText: translate("listHint"),
            ),
            onChanged: (String newString) =>
                widget.updateParamName(widget.itemCount, newString),
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
