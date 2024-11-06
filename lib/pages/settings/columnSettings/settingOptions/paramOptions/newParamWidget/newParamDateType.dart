import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';

class NewParamDateType extends StatelessWidget {
  final bool dateT;
  final String selectedType;
  const NewParamDateType(
      {super.key, required this.dateT, required this.selectedType});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !dateT,
      child: Expanded(
        flex: 2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Text(selectedType,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
