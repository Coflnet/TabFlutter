import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class CsvExportConfirmExport extends StatelessWidget {
  final VoidCallback closePopup;
  const CsvExportConfirmExport({super.key, required this.closePopup});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () {
          closePopup();
        },
        child: Container(
          alignment: Alignment.center,
          height: 30,
          width: double.infinity,
          decoration: BoxDecoration(
              color: HexColor("8332AC"),
              borderRadius: BorderRadius.circular(6)),
          child: const Text(
            "Export",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ));
  }
}
