import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/columnNameOption.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/paramOptionsMaim.dart';

class ColumnSettingsPopup extends StatefulWidget {
  const ColumnSettingsPopup({Key? key}) : super(key: key);

  @override
  _ColumnSettingsPopupState createState() => _ColumnSettingsPopupState();
}

class _ColumnSettingsPopupState extends State<ColumnSettingsPopup> {
  Map filledIn = {"ColName": false, "paramsFilledIn": false};

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
            const Expanded(
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
            TextButton(
                onPressed: () {},
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: HexColor("8332AC"),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    "Confirm",
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
