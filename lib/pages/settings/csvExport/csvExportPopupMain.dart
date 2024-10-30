import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/pages/settings/csvExport/csvExportDateSelect.dart';
import 'package:table_entry/pages/settings/csvExport/csvExportFileName.dart';
import 'package:table_entry/pages/settings/csvExport/csvExportOptionsHeader.dart';
import 'package:table_entry/pages/settings/csvExport/csvExportTableSelect.dart';

class CsvExportPopupMain extends StatefulWidget {
  final VoidCallback closePopup;
  const CsvExportPopupMain({super.key, required this.closePopup});

  @override
  State<CsvExportPopupMain> createState() => _CsvExportPopupMainState();
}

class _CsvExportPopupMainState extends State<CsvExportPopupMain> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: HexColor("1D1E2B"), borderRadius: BorderRadius.circular(16)),
      width: MediaQuery.sizeOf(context).width * 0.8,
      height: MediaQuery.sizeOf(context).height * 0.65,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: [
              CsvExportFileName(fileNameChanged: () {}),
              const CsvExportOptionsHeader(),
              const CsvExportTableSelect(),
              const SizedBox(height: 12),
              const CsvExportDateSelect(),
              Expanded(child: SizedBox()),
            ],
          ),
          IconButton(
              onPressed: () {
                widget.closePopup();
              },
              icon: Icon(
                Icons.close_rounded,
                size: 37,
                color: Colors.grey.shade400,
              ))
        ],
      ),
    );
  }
}
