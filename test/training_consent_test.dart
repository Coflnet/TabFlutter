import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/pages/main/listeningMode/training_consent_dialog.dart';

final notice = <String, dynamic>{
  'version': 'test-v1',
  'information': 'Informationen',
  'terms': 'Bedingungen',
  'privacyUrl': 'https://coflnet.com/de/privacy/',
  'purposes': [
    {'value': 1, 'title': 'Forschung', 'description': 'Archiv'},
    {'value': 4, 'title': 'Training', 'description': 'Spracherkennung'},
  ],
};

void main() {
  setUp(() => Localization.load({'trainingConsentAccept': 'Einwilligen'}));

  testWidgets(
      'training consent is unticked and only the training purpose is offered',
      (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showDialog<bool>(
              context: context,
              builder: (_) => TrainingConsentDialog(notice: notice)),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Forschung'), findsNothing);
    final checkbox =
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
    expect(checkbox.value, isFalse);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);

    await tester.tap(find.text('Training'));
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
