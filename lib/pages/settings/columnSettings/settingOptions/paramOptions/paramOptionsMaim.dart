import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 12),
        ParamOptionsHeader(
          addNewParam: addNewCount,
        ),
        ListView.builder(
          itemCount: count,
          itemBuilder: (context, index) {
            return NewParam();
          },
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        )
      ],
    );
  }

  void addNewCount() {
    setState(() {
      count++;
    });
  }

  void updateParamNames(int item, String newString) {
    setState(() {
      paramNames[item] = newString;
    });
    print(paramNames);
  }
}
