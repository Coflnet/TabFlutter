import 'package:flutter/material.dart';
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
    return SizedBox.shrink(
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
        width: 30,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(31, 215, 212, 255), width: 2),
                  borderRadius: BorderRadius.circular(8)),
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: const InputDecoration.collapsed(
                  hintStyle: TextStyle(color: Colors.white30),
                  hintText: "List name",
                ),
                onChanged: (String newString) =>
                    widget.updateParamName(widget.itemCount, newString),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
