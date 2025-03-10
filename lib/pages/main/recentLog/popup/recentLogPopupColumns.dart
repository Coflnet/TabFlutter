import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogDateColumn.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopupEditBox.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopupListOption.dart';

class RecentLogPopupColumns extends StatefulWidget {
  final List<param> params;
  const RecentLogPopupColumns({super.key, required this.params});

  @override
  _RecentLogPopupColumnsState createState() => _RecentLogPopupColumnsState();
}

class _RecentLogPopupColumnsState extends State<RecentLogPopupColumns> {
  @override
  void initState() {
    super.initState();
    handleTranslate();
    print(widget.params.toString());
  }

  void handleTranslate() {
    if (SaveColumn().getlanguage == "en") {
      return;
    }
    List enList = ["List", "Number", "String", "Date"];
    for (var element in widget.params) {
      if (enList.contains(element.type)) {
        element.type = enList[enList.indexOf(element.type)];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Text(
            translate("columns"),
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: (1 / .60),
                    crossAxisCount: 2,
                    mainAxisSpacing: 13,
                    crossAxisSpacing: 8),
                shrinkWrap: true,
                itemCount: widget.params.length,
                itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                          color: HexColor("23263E"),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.params[index].name.capitalize(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          getWidget(widget.params[index].type, index),
                        ],
                      ),
                    )),
          )
        ],
      ),
    );
  }

  Widget getWidget(String value, int index) {
    if (value == translate("List")) {
      return RecentLogPopupListOption(
          types: widget.params[index].listOption ?? [],
          selectedValue: widget.params[index].svalue ?? "",
          index: index);
    } else if (value == translate("Date")) {
      return RecentLogDateColumn(
          index: index, dateTimeString: widget.params[index].svalue ?? "");
    } else {
      return RecentLogPopupEditBox(
          name: widget.params[index].svalue ?? "",
          isNumber: (widget.params[index].type == "Number"),
          index: index);
    }
  }
}
