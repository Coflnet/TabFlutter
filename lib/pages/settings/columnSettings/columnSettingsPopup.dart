import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsNotifer.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/columnNameOption.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/paramOptionsMaim.dart';
import 'package:table_entry/pages/settings/table_settings_page.dart';

class ColumnSettingsPopup extends StatefulWidget {
  final bool isShowing;
  final VoidCallback closePopup;

  const ColumnSettingsPopup(
      {super.key, required this.isShowing, required this.closePopup});

  @override
  _ColumnSettingsPopupState createState() => _ColumnSettingsPopupState();
}

class _ColumnSettingsPopupState extends State<ColumnSettingsPopup> {
  Map filledIn = {"ColName": false, "paramsFilledIn": false};

  @override
  void initState() {
    super.initState();
  }

  void sendUpdate() async {
    await Future.delayed(const Duration(milliseconds: 50));
    popupNotifyer().sendUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: HexColor("1D1E2B"), borderRadius: BorderRadius.circular(16)),
        width: MediaQuery.sizeOf(context).width * 0.8,
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: Column(
          children: [
            ChangeNotifierProvider(
              create: (context) => popupNotifyer(),
              child: const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      ColumnNameOption(),
                      ParamOptionsMaim()
                    ],
                  ),
                ),
              ),
            ),
            TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TableSettingsPage(
                          table: EditingColumns().getEditingCol),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.settings, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Table Settings",
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  SaveColumn().saveColumn(EditingColumns().getEditingCol.id,
                      EditingColumns().getEditingCol);
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
        ));
  }

  void paramsFilledIn(String param, bool filledIn) {}
}
