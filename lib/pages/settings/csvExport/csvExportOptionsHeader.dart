import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class CsvExportOptionsHeader extends StatelessWidget {
  const CsvExportOptionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              translate("options"),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}
