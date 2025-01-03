import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PickLanguage extends StatelessWidget {
  final String currentLocaleId;

  final List<LocaleName> localeNames;

  const PickLanguage(
      {Key? key, required this.currentLocaleId, required this.localeNames})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Sprache: '),
        DropdownButton<String>(
          onChanged: (selectedVal) => switchLang(selectedVal),
          value: currentLocaleId,
          items: localeNames
              .map(
                (localeName) => DropdownMenuItem(
                  value: localeName.localeId,
                  child: Text(localeName.name),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void switchLang(i) {}
}
