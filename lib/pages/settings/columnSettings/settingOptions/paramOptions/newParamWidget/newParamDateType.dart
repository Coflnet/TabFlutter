import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NewParamDateType extends StatelessWidget {
  final bool dateT;
  const NewParamDateType({super.key, required this.dateT});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !dateT,
      child: Expanded(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Text(translate("date"),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
