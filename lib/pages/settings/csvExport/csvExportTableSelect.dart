import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/columnsDataProccessing.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';

class CsvExportTableSelect extends StatefulWidget {
  const CsvExportTableSelect({super.key});

  @override
  State<CsvExportTableSelect> createState() => _CsvExportTableSelectState();
}

class _CsvExportTableSelectState extends State<CsvExportTableSelect> {
  List<DropdownMenuItem> items = [];
  String selectedValue =
      SaveColumn().getColumns[SaveColumn().getSelcColumn].name;

  @override
  void initState() {
    super.initState();
    for (var i in SaveColumn().getColumns) {
      items.add(
        DropdownMenuItem<String>(
          value: i.name,
          child: Text(
            i.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    ColumnsDataProccessing().setSelectedColumn = selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
          color: HexColor("23263E"), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            translate("exTable"),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const Expanded(child: SizedBox()),
          Container(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
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
                          fontSize: 22,
                          fontWeight: FontWeight.w600),
                      items: items,
                      value: selectedValue,
                      onChanged: (value) => {
                            ColumnsDataProccessing().setSelectedColumn = value,
                            setState(() {
                              selectedValue = value;
                            })
                          }))),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
