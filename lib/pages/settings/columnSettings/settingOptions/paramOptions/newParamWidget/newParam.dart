import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/newParamWidget/newParamNameType.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/newlistParam/newListParamMain.dart';

class NewParam extends StatefulWidget {
  const NewParam({Key? key}) : super(key: key);

  @override
  _NewParamState createState() => _NewParamState();
}

class _NewParamState extends State<NewParam>
    with SingleTickerProviderStateMixin {
  String type = "String";
  bool displayListType = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        decoration: BoxDecoration(
            color: HexColor("23263E"), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: <Widget>[
            NewParamNameType(updateType: changeType),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: displayListType
                  ? SlideTransition(
                      position: _offsetAnimation, child: NewListParamMain())
                  : const SizedBox.shrink(),
            ),
          ],
        ));
  }

  void changeType(String newType) {
    if (newType == "List") {
      setState(() {
        displayListType = true;
        type = "List";
      });
      _controller.forward();
    } else {
      setState(() {
        displayListType = false;
        type = newType;
      });
      _controller.reverse();
    }
  }
}
