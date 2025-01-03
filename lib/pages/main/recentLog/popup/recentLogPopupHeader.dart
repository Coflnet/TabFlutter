import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:spables/globals/columns/editingColumns.dart';
import 'package:spables/pages/settings/columnSettings/columnSettingsNotifer.dart';

class RecentLogPopupHeader extends StatefulWidget {
  const RecentLogPopupHeader({Key? key}) : super(key: key);

  @override
  _RecentLogPopupHeaderState createState() => _RecentLogPopupHeaderState();
}

class _RecentLogPopupHeaderState extends State<RecentLogPopupHeader> {
  String name = EditingColumns().getEditingCol.name;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      interact();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<recnetLogPopupNotifer>(builder: (context, value, child) {
      return Container(
        margin: EdgeInsets.only(top: 12),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Transform.translate(
              offset: const Offset(9, -7),
              child: IconButton(
                  style: IconButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {},
                  icon: Icon(
                    Icons.delete_outline,
                    size: 28,
                    color: Colors.redAccent.shade700,
                  )),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Recent log",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 23),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void interact() {
    print(name);
    setState(() {
      name = EditingColumns().getEditingCol.name;
    });
    print(name);
  }
}
