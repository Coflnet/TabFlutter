import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';

class RecentLogPopupEditBox extends StatefulWidget {
  final String name;
  final int index;
  final bool isNumber;
  const RecentLogPopupEditBox(
      {super.key,
      required this.name,
      required this.isNumber,
      required this.index});

  @override
  _RecentLogPopupEditBoxState createState() => _RecentLogPopupEditBoxState();
}

class _RecentLogPopupEditBoxState extends State<RecentLogPopupEditBox> {
  late TextEditingController controller;
  String hintText = "NA";
  @override
  void initState() {
    super.initState();
    controller =
        TextEditingController(text: (widget.name == "") ? "N/A" : widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        decoration: BoxDecoration(
            color: HexColor("2A2D54"), borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: <Widget>[
            TextField(
              controller: controller,
              keyboardType:
                  widget.isNumber ? TextInputType.number : TextInputType.text,
              textAlign: TextAlign.center,
              decoration: InputDecoration.collapsed(
                hintStyle: const TextStyle(color: Colors.white30),
                hintText: hintText,
              ),
              onChanged: (String newString) {
                updateParamName(newString);
              },
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 2, 2, 0),
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            )
          ],
        ));
  }

  void updateParamName(String newString) {
    EditingColumns().updateParam(widget.index, "value", newString);
  }
}
