import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogColumns.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopupColumns.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopupHeader.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsNotifer.dart';

class RecentLogPopup extends StatefulWidget {
  final VoidCallback closePopup;
  const RecentLogPopup({super.key, required this.closePopup});

  @override
  _RecentLogPopupState createState() => _RecentLogPopupState();
}

class _RecentLogPopupState extends State<RecentLogPopup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: HexColor("1D1E2B"), borderRadius: BorderRadius.circular(16)),
      width: MediaQuery.sizeOf(context).width * 0.8,
      height: 400,
      child: ChangeNotifierProvider(
        create: (context) => recnetLogPopupNotifer(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const RecentLogPopupHeader(),
                  const SizedBox(height: 8),
                  RecentLogPopupColumns(
                      params: EditingColumns().getEditingCol.params),
                ],
              ),
            ),
            TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  EditingColumns().saveCol();
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
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
