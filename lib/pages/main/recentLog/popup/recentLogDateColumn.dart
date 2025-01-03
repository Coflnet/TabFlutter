import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:spables/globals/columns/editingColumns.dart';

class RecentLogDateColumn extends StatefulWidget {
  final String dateTimeString;
  final int index;
  const RecentLogDateColumn(
      {super.key, required this.dateTimeString, required this.index});

  @override
  State<RecentLogDateColumn> createState() => _RecentLogDateColumnState();
}

class _RecentLogDateColumnState extends State<RecentLogDateColumn> {
  late String selectedDate = widget.dateTimeString;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked.toIso8601String() != selectedDate) {
      setState(() {
        selectedDate = picked.toIso8601String();

        EditingColumns().updateParam(widget.index, "value", selectedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.dateTimeString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
          color: HexColor("2A2D54"), borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: TextButton(
        style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
        onPressed: () => _selectDate(context),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat("MMMd").format(DateTime.parse(selectedDate)),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 2, 2, 0),
              child: Icon(
                Icons.edit,
                size: 16,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
