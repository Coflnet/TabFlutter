import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/newParamWidget/newParamNameType.dart';
import 'package:table_entry/pages/settings/columnSettings/settingOptions/paramOptions/newlistParam/newListParamMain.dart';

class NewParam extends StatefulWidget {
  final int index;
  final bool update;
  const NewParam({
    super.key,
    required this.index,
    required this.update,
  });

  @override
  _NewParamState createState() => _NewParamState();
}

class _NewParamState extends State<NewParam>
    with SingleTickerProviderStateMixin {
  String type = "String";
  bool displayListType = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late TextEditingController controller;

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
    updateParamParams();
  }

  void updateParamParams() {
    setState(() {
      type = EditingColumns().getEditingCol.params[widget.index].type;
    });
    print(type);
    if (type == translate("optionList")) {
      setState(() {
        displayListType = true;
      });
      print(EditingColumns().getEditingCol.params[widget.index].listOption);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        decoration: BoxDecoration(
            color: HexColor("23263E"), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: <Widget>[
            NewParamNameType(
                updateType: changeType,
                selectedValue: type,
                index: widget.index),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: displayListType
                  ? SlideTransition(
                      position: _offsetAnimation,
                      child: NewListParamMain(
                        index: widget.index,
                        storedList: EditingColumns()
                                .getEditingCol
                                .params[widget.index]
                                .listOption ??
                            [],
                      ))
                  : const SizedBox.shrink(),
            ),
          ],
        ));
  }

  void changeType(String newType) {
    EditingColumns().updateParam(widget.index, "type", newType);
    if (newType == translate("optionList")) {
      setState(() {
        displayListType = true;
        type = translate("optionList");
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
