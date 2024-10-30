import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class CsvExportDateSelect extends StatefulWidget {
  const CsvExportDateSelect({super.key});

  @override
  State<CsvExportDateSelect> createState() => _CsvExportDateSelectState();
}

class _CsvExportDateSelectState extends State<CsvExportDateSelect> {
  DateTime? selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: HexColor("23263E"), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Text(
            translate("exAfter"),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const Expanded(child: SizedBox()),
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => _selectDate(context),
            child: Container(
              constraints: const BoxConstraints(minWidth: 90),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: HexColor("2A2D54"),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                    selectedDate != null
                        ? DateFormat("MMMd").format(selectedDate!)
                        : "NA"),
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
