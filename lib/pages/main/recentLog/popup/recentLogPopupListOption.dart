import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';

class RecentLogPopupListOption extends StatefulWidget {
  String selectedValue;
  final int index;
  RecentLogPopupListOption(
      {super.key, required this.selectedValue, required this.index});

  @override
  _RecentLogPopupListOptionState createState() =>
      _RecentLogPopupListOptionState();
}

class _RecentLogPopupListOptionState extends State<RecentLogPopupListOption> {
  final List<String> items = ["String", "0/10", "List"];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: HexColor("2A2D54"), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
          child: DropdownButton2(
        style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
                color: HexColor("2A2D54"),
                borderRadius: BorderRadius.circular(8)),
            offset: const Offset(0, -10)),
        value: widget.selectedValue,
        onChanged: (newVal) {
          setState(() {
            widget.selectedValue = newVal ?? widget.selectedValue;
          });
          EditingColumns()
              .updateParam(widget.index, "svalue", widget.selectedValue);
        },
        items: items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ))
            .toList(),
      )),
    );
  }
}