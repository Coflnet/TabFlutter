import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsNotifer.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/columnNameOption.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/paramOptionsMaim.dart';

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
        height: 400,
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
