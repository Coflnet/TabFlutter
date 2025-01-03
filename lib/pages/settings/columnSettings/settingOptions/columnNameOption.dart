import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:spables/globals/columns/editingColumns.dart';
import 'package:spables/pages/settings/columnSettings/columnSettingsNotifer.dart';
import 'package:spables/pages/settings/columnSettings/emojiPopup/columnEmojiPopup.dart';

class ColumnNameOption extends StatefulWidget {
  const ColumnNameOption({Key? key}) : super(key: key);

  @override
  _ColumnNameOptionState createState() => _ColumnNameOptionState();
}

class _ColumnNameOptionState extends State<ColumnNameOption> {
  bool isCompleted = false;
  late TextEditingController controller;
  String displayedName = "";

  void reactToNotifer() {
    controller.text = EditingColumns().getEditingCol.name;
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<popupNotifyer>(
      builder: (context, value, child) {
        reactToNotifer();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    translate("nameOption"),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.fromLTRB(6, 3, 3, 6),
                    decoration: BoxDecoration(
                        color: HexColor("23263E"),
                        borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      maxLength: 8,
                      controller: controller,
                      onChanged: updateText,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        counterText: "",
                        hintStyle: const TextStyle(color: Colors.white30),
                        hintText: translate("hintTableName"),
                      ),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
            ),
            ColumnEmojiPopup(),
            const SizedBox(width: 3.5)
          ],
        );
      },
    );
  }

  void updateText(String newText) {
    EditingColumns().updateName(newText);
  }
}
