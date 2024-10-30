import 'package:flutter/material.dart';

class CsvExportConfirmExport extends StatelessWidget {
  const CsvExportConfirmExport({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () {
          widget.closePopup();
        },
        child: Container(
          alignment: Alignment.center,
          height: 30,
          width: double.infinity,
          decoration: BoxDecoration(
              color: HexColor("8332AC"),
              borderRadius: BorderRadius.circular(6)),
          child: const Text(
            "Save",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ));
  }
}
