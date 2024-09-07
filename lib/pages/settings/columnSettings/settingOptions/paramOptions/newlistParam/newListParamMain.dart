import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/newlistParam/newListParam.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/newlistParam/newListParamHeader.dart';

class NewListParamMain extends StatefulWidget {
  const NewListParamMain({Key? key}) : super(key: key);

  @override
  _NewListParamMainState createState() => _NewListParamMainState();
}

class _NewListParamMainState extends State<NewListParamMain> {
  List paramNames = [""];
  int itemCount = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: <Widget>[
          NewListParamHeader(addCount: addItemCount),
          GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: (1 / .25),
                  crossAxisCount: 2,
                  mainAxisSpacing: 13,
                  crossAxisSpacing: 8),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return NewListParam(
                    itemCount: index, updateParamName: updateParamNames);
              })
        ],
      ),
    );
  }

  void addItemCount() {
    setState(() {
      itemCount += 1;
      paramNames.add("");
    });
  }

  void updateParamNames(int item, String newString) {
    setState(() {
      paramNames[item] = newString;
    });
  }

  void checkFilledIn() {
    bool isFilled = true;
    paramNames.forEach((value) {
      if (value.isEmpty) {
        isFilled = false;
      }
    });
    if (!isFilled) {}
  }
}