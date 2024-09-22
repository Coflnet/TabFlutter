import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
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
    print(widget.params.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const Text(
            "Columns",
            style: TextStyle(
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
                          (widget.params[index].type == "List")
                              ? RecentLogPopupListOption(
                                  selectedValue:
                                      widget.params[index].svalue ?? "",
                                  index: index)
                              : RecentLogPopupEditBox(
                                  name: widget.params[index].svalue ?? "",
                                  isNumber:
                                      (widget.params[index].type == "0/10"),
                                  index: index)
                        ],
                      ),
                    )),
          )
        ],
      ),
    );
  }
}
