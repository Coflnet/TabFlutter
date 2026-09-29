import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:table_entry/generatedCode/api.dart';
import 'package:table_entry/globals/recentLogRequest/recognize_session.dart';

void main() {
  test('first chunk sends empty pending state', () {
    final s = RecognizeSession('s1');
    expect(s.pendingTexts, isEmpty);
    expect(s.pendingAudioIds, isEmpty);
  });

  test('incomplete response carries texts and audio ids to the next chunk', () {
    final s = RecognizeSession('s1');
    s.apply(isComplete: false, pendingTexts: ['Neue'], audioIds: ['a.opus']);
    expect(s.pendingTexts, ['Neue']);
    expect(s.pendingAudioIds, ['a.opus']);
    s.apply(
        isComplete: false,
        pendingTexts: ['Neue', 'Bestellung'],
        audioIds: ['a.opus', 'b.opus']);
    expect(s.pendingTexts, ['Neue', 'Bestellung']);
    expect(s.pendingAudioIds, ['a.opus', 'b.opus']);
  });

  test('complete response resets the state', () {
    final s = RecognizeSession('s1');
    s.apply(isComplete: false, pendingTexts: ['x'], audioIds: ['a.opus']);
    s.apply(isComplete: true, pendingTexts: ['ignored'], audioIds: ['a.opus']);
    expect(s.pendingTexts, isEmpty);
    expect(s.pendingAudioIds, isEmpty);
  });

  test('missing fields from an old server reset to empty lists', () {
    final s = RecognizeSession('s1');
    s.apply(isComplete: false, pendingTexts: ['x'], audioIds: ['a.opus']);
    s.apply(isComplete: false);
    expect(s.pendingTexts, isEmpty);
    expect(s.pendingAudioIds, isEmpty);
  });

  test('a failed chunk leaves the state unchanged, so a retry resends it',
      () async {
    final s = RecognizeSession('s1');
    s.apply(isComplete: false, pendingTexts: ['a'], audioIds: ['1.opus']);
    final sent = <List<String>>[];
    Future<void> chunk({required bool fail}) => s.run(() async {
          sent.add(s.pendingTexts);
          if (fail) throw Exception('502');
          s.apply(
              isComplete: false,
              pendingTexts: [...s.pendingTexts, 'b'],
              audioIds: [...s.pendingAudioIds, '2.opus']);
        });
    await expectLater(chunk(fail: true), throwsException);
    await chunk(fail: false);
    expect(sent, [
      ['a'],
      ['a']
    ]);
    expect(s.pendingTexts, ['a', 'b']);
  });

  test('overlapping chunks run in order and see the previous result', () async {
    final s = RecognizeSession('s1');
    final gate = Completer<void>();
    final seen = <List<String>>[];
    final first = s.run(() async {
      seen.add(s.pendingTexts);
      await gate.future;
      s.apply(isComplete: false, pendingTexts: ['eins'], audioIds: ['1.opus']);
    });
    final second = s.run(() async {
      seen.add(s.pendingTexts);
      s.apply(isComplete: true);
    });
    await Future<void>.delayed(Duration.zero);
    expect(seen, [<String>[]]);
    gate.complete();
    await Future.wait([first, second]);
    expect(seen, [
      <String>[],
      ['eins']
    ]);
    expect(s.pendingTexts, isEmpty);
  });

  test('request and response models carry the new fields', () {
    final json = RecognitionRequest(
      sessionId: 's1',
      pendingTexts: const [],
      pendingAudioIds: const ['a.opus'],
      timeZone: 'Europe/Berlin',
    ).toJson();
    expect(json['pendingTexts'], isEmpty);
    expect(json['pendingTexts'], isNotNull);
    expect(json['pendingAudioIds'], ['a.opus']);
    expect(json['timeZone'], 'Europe/Berlin');

    final resp = RecognitionResponse.fromJson({
      'isComplete': false,
      'text': 'Neue',
      'columnWithText': [],
      'audioIds': ['a.opus'],
      'pendingTexts': ['Neue'],
    })!;
    expect(resp.pendingTexts, ['Neue']);
    expect(RecognitionResponse.fromJson({'isComplete': true})!.pendingTexts,
        isNull);
    expect(
        RecognitionRequest.fromJson(json),
        RecognitionRequest(
          sessionId: 's1',
          columnWithDescription: const {},
          pendingTexts: const [],
          pendingAudioIds: const ['a.opus'],
          timeZone: 'Europe/Berlin',
        ));
  });
}
