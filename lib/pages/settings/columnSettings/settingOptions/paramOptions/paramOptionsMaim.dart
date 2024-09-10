import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsNotifer.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/newParamWidget/newParam.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/paramOptionsHeader.dart';

class ParamOptionsMaim extends StatefulWidget {
  const ParamOptionsMaim({Key? key}) : super(key: key);

  @override
  _ParamOptionsMaimState createState() => _ParamOptionsMaimState();
}

class _ParamOptionsMaimState extends State<ParamOptionsMaim> {
  int count = 1;
  List paramNames = [""];
  bool forceUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reactToNotifer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<popupNotifyer>(builder: (context, value, child) {
      return Column(
        children: <Widget>[
          const SizedBox(height: 12),
          ParamOptionsHeader(
            addNewParam: addNewCount,
          ),
          ListView.builder(
            itemCount: count,
            itemBuilder: (context, index) {
              return NewParam(index: index, update: forceUpdate);
            },
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          )
        ],
      );
    });
  }

  void reactToNotifer() {
    print("hi");
    setState(() {
      count = EditingColumns().getEditingCol.params.length;
      forceUpdate = true;
    });
  }

  void addNewCount() {
    EditingColumns().addNewParam();
    setState(() {
      count += 1;
    });
  }

  void updateParamNames(int item, String newString) {
    setState(() {
      paramNames[item] = newString;
    });
  }
}
