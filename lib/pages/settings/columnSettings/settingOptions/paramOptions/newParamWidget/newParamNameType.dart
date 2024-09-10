import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/main.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/newParamWidget/newParamNameOption.dart';

class NewParamNameType extends StatefulWidget {
  final Function(String) updateType;
  final int index;
  final String selectedValue;

  const NewParamNameType({
    super.key,
    required this.updateType,
    required this.selectedValue,
    required this.index,
  });

  @override
  _NewParamNameTypeState createState() => _NewParamNameTypeState();
}

class _NewParamNameTypeState extends State<NewParamNameType> {
  final List<String> items = ["String", "0/10", "List"];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        NewParamNameOption(index: widget.index),
        Expanded(
          child: Column(
            children: <Widget>[
              const Text(
                "Type",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                  decoration: BoxDecoration(
                      color: HexColor("2A2D54"),
                      borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                    dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                            color: HexColor("2A2D54"),
                            borderRadius: BorderRadius.circular(8)),
                        offset: const Offset(0, -10)),
                    isDense: true,
                    hint: Text(
                      'Select Item',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
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
                    value: widget.selectedValue,
                    onChanged: (value) =>
                        {widget.updateType(value ?? widget.selectedValue)},
                  )))
            ],
          ),
        )
      ],
    );
  }
}
