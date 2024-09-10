import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsNotifer.dart';

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
    print("react");
    setState(() {
      name = EditingColumns().getEditingCol.params[widget.index].name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<popupNotifyer>(builder: (context, value, child) {
      return Expanded(
        child: Column(
          children: <Widget>[
            const Text(
              "Name",
              style: TextStyle(
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
                controller: controller,
                decoration: const InputDecoration.collapsed(
                  hintStyle: TextStyle(color: Colors.white30),
                  hintText: "Set name",
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
