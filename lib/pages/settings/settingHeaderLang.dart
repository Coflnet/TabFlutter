import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:restart_app/restart_app.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';

class SettingHeaderLang extends StatefulWidget {
  const SettingHeaderLang({Key? key}) : super(key: key);

  @override
  _SettingHeaderLangState createState() => _SettingHeaderLangState();
}

class _SettingHeaderLangState extends State<SettingHeaderLang> {
  String selectedValue = SaveColumn().getlanguage == "en" ? "🇺🇸" : "🇩🇪";
  final List<String> items = ["🇺🇸", "🇩🇪"];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Text("🌍 ", style: TextStyle(fontSize: 28)),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: HexColor("242536"),
              borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
              child: DropdownButton2(
            iconStyleData: const IconStyleData(iconSize: 0),
            dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                    color: HexColor("242536"),
                    borderRadius: BorderRadius.circular(8)),
                offset: const Offset(0, -10)),
            isDense: true,
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ))
                .toList(),
            value: selectedValue,
            onChanged: (value) => setState(() {
              selectedValue = value ?? selectedValue;
              changeSelectedLanguage();
            }),
          )),
        )
      ],
    );
  }

  void changeSelectedLanguage() {
    switch (selectedValue) {
      case "🇺🇸":
        changeLocale(context, "en");
        SaveColumn().setlanguage = "en";
        SaveColumn().saveFile();
      case "🇩🇪":
        changeLocale(context, "de");
        SaveColumn().setlanguage = "de";
        SaveColumn().saveFile();
    }
    Restart.restartApp();
  }
}
