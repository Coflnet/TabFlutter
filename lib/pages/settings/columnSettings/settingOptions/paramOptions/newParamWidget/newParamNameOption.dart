import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:spables/globals/columns/editingColumns.dart';
import 'package:spables/pages/settings/columnSettings/columnSettingsNotifer.dart';

class NewParamNameOption extends StatefulWidget {
  final int index;
  const NewParamNameOption({super.key, required this.index});

  @override
  _NewParamNameOptionState createState() => _NewParamNameOptionState();
}

class _NewParamNameOptionState extends State<NewParamNameOption> {
  late TextEditingController controller;
  String name = "";

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: "");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reactToNotifer();
    });
  }

  void reactToNotifer() async {
    setState(() {
      name = EditingColumns().getEditingCol.params[widget.index].name;
    });
    controller.text = name;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<popupNotifyer>(builder: (context, value, child) {
      return Expanded(
        flex: 3,
        child: Column(
          children: <Widget>[
            Text(
              translate("newHeader"),
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 0, 6),
              margin: const EdgeInsets.fromLTRB(8, 0, 12, 0),
              decoration: BoxDecoration(
                  color: HexColor("2A2D54"),
                  borderRadius: BorderRadius.circular(8)),
              child: TextField(
                maxLengthEnforcement:
                    MaxLengthEnforcement.truncateAfterCompositionEnds,
                maxLength: 24,
                controller: controller,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  counterText: "",
                  hintStyle: const TextStyle(color: Colors.white30),
                  hintText: translate("setNameHint"),
                ),
                onChanged: (value) {
                  EditingColumns().updateParam(widget.index, "name", value);
                },
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            )
          ],
        ),
      );
    });
  }
}
