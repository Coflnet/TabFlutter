import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:spables/globals/columns/columnsDataProccessing.dart';
import 'package:spables/globals/recentLogRequest/recentLogHandler.dart';

class CsvExportFileName extends StatefulWidget {
  final VoidCallback fileNameChanged;
  const CsvExportFileName({super.key, required this.fileNameChanged});

  @override
  State<CsvExportFileName> createState() => _CsvExportFileNameState();
}

class _CsvExportFileNameState extends State<CsvExportFileName> {
  late TextEditingController controller;
  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
        text:
            "${RecentLogHandler().getCurrentSelected.name}-${DateFormat("MMM-d").format(DateTime.now())}");
    ColumnsDataProccessing().setFileName = controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text("File Name",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.white)),
        Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 0, 6),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
              color: HexColor("2A2D54"),
              borderRadius: BorderRadius.circular(8)),
          child: TextField(
            maxLength: 35,
            controller: controller,
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              counterText: "",
              hintStyle: TextStyle(color: Colors.white30),
            ),
            onChanged: (value) {
              ColumnsDataProccessing().setFileName = value;
              widget.fileNameChanged();
            },
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
