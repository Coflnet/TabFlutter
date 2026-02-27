import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editingColumns.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopupColumns.dart';
import 'package:table_entry/pages/main/recentLog/popup/recentLogPopupHeader.dart';
import 'package:table_entry/pages/settings/columnSettings/columnSettingsNotifer.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';

class RecentLogPopup extends StatefulWidget {
  final VoidCallback closePopup;

  const RecentLogPopup({super.key, required this.closePopup});

  @override
  _RecentLogPopupState createState() => _RecentLogPopupState();
}

class _RecentLogPopupState extends State<RecentLogPopup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: HexColor("1D1E2B"), borderRadius: BorderRadius.circular(16)),
      width: MediaQuery.sizeOf(context).width * 0.8,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        minHeight: 200,
      ),
      child: ChangeNotifierProvider(
        create: (context) => recnetLogPopupNotifer(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    RecentLogPopupHeader(closePopup: widget.closePopup),
                    const SizedBox(height: 8),
                    RecentLogPopupColumns(
                        params: EditingColumns().getEditingCol.params),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
              child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    EditingColumns().saveCol();
                    Provider.of<UpdateRecentLog>(context, listen: false)
                        .recentLogUpdate();
                    widget.closePopup();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: HexColor("8332AC"),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      translate("save"),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
