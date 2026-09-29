import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_entry/globals/integration_service.dart';

/// Fake backend: `/pair` hands out a push token, `/entries` answers with
/// [entriesStatus] (or throws when it is null).
class FakeBackend {
  int? entriesStatus = 200;
  final received = <Map<String, dynamic>>[];
  final pushTokens = <String>[];
  int pairCount = 0;

  late final client = MockClient((request) async {
    switch (request.url.path) {
      case '/api/integration/pair':
        final code = jsonDecode(request.body)['code'];
        if (code != 'ABCD-EFGH') {
          return http.Response('{"error":"unknown"}', 404);
        }
        pairCount++;
        return http.Response(
            jsonEncode({
              'integrationId': 'int-1',
              'integrationType': 'excel',
              'label': 'Bestellungen.xlsx',
              'pushToken': 'push-$pairCount',
            }),
            200);
      case '/api/integration/entries':
        final status = entriesStatus;
        if (status == null) throw http.ClientException('offline');
        pushTokens.add(request.headers['X-Integration-Push-Token'] ?? '');
        if (status == 200) received.add(jsonDecode(request.body));
        return http.Response(status == 200 ? '{}' : '{"error":"x"}', status);
    }
    return http.Response('', 404);
  });

  IntegrationService service() =>
      IntegrationService.forTesting(client: client, baseUrl: 'https://test');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('pairing code', () {
    test('normalizes case, spaces and dashes', () {
      expect(IntegrationService.normalizePairingCode('abcd-efgh'), 'ABCD-EFGH');
      expect(
          IntegrationService.normalizePairingCode(' abcd efgh '), 'ABCD-EFGH');
      expect(IntegrationService.normalizePairingCode('ABCDEFGH'), 'ABCD-EFGH');
      expect(
          IntegrationService.normalizePairingCode('ab cd-ef gh'), 'ABCD-EFGH');
      expect(IntegrationService.normalizePairingCode('k7m2–x9pq'), 'K7M2-X9PQ');
    });

    test('rejects wrong length and characters outside the alphabet', () {
      expect(IntegrationService.normalizePairingCode(''), isNull);
      expect(IntegrationService.normalizePairingCode('ABCD-EFG'), isNull);
      expect(IntegrationService.normalizePairingCode('ABCD-EFGHJ'), isNull);
      expect(IntegrationService.normalizePairingCode('ABCD-EFG0'), isNull);
      expect(IntegrationService.normalizePairingCode('ABCD-EFG1'), isNull);
      expect(IntegrationService.normalizePairingCode('ABCD-EFGO'), isNull);
      expect(IntegrationService.normalizePairingCode('ABCD-EFGI'), isNull);
      expect(IntegrationService.normalizePairingCode('ÄBCD-EFGH'), isNull);
    });

    test('pair stores the integration in shared_preferences', () async {
      final backend = FakeBackend();
      final paired = await backend.service().pair('abcd efgh');
      expect(paired.pushToken, 'push-1');
      expect(paired.label, 'Bestellungen.xlsx');

      final reloaded = backend.service();
      await reloaded.load();
      expect(reloaded.integrations.single.integrationId, 'int-1');
      expect(reloaded.integrations.single.pushToken, 'push-1');
    });

    test('unknown code and bad input raise typed errors', () async {
      final service = FakeBackend().service();
      await expectLater(
          service.pair('ZZZZ-ZZZZ'),
          throwsA(isA<PairingException>()
              .having((e) => e.error, 'error', PairingError.notFound)));
      await expectLater(
          service.pair('abc'),
          throwsA(isA<PairingException>()
              .having((e) => e.error, 'error', PairingError.invalidCode)));
      expect(service.integrations, isEmpty);
    });
  });

  group('push and outbox', () {
    test('sends each line with a uuid v4 entryId and the push token', () async {
      final backend = FakeBackend();
      final service = backend.service();
      await service.pair('ABCD-EFGH');
      await service.pushEntry({'Artikel': 'Flansch DN50', 'Menge': '20'});

      expect(backend.received, hasLength(1));
      expect(backend.received.single['data'],
          {'Artikel': 'Flansch DN50', 'Menge': '20'});
      expect(
          backend.received.single['entryId'],
          matches(RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      expect(backend.pushTokens.single, 'push-1');
      expect(service.outbox, isEmpty);
    });

    test('no integration paired: nothing is queued', () async {
      final service = FakeBackend().service();
      await service.pushEntry({'a': 'b'});
      expect(service.outbox, isEmpty);
    });

    test('network error and 5xx keep the entry; retry sends the same entryId',
        () async {
      final backend = FakeBackend();
      final service = backend.service();
      await service.pair('ABCD-EFGH');

      backend.entriesStatus = null; // offline
      await service.pushEntry({'n': '1'});
      backend.entriesStatus = 502;
      await service.pushEntry({'n': '2'});
      expect(service.outbox.map((i) => i.data['n']), ['1', '2']);
      final ids = service.outbox.map((i) => i.entryId).toList();

      // Survives an app restart.
      final restarted = backend.service();
      await restarted.load();
      expect(restarted.outbox.map((i) => i.entryId), ids);

      backend.entriesStatus = 200;
      await restarted.flushOutbox();
      expect(restarted.outbox, isEmpty);
      expect(backend.received.map((r) => r['entryId']), ids);
      expect(backend.received.map((r) => r['data']['n']), ['1', '2']);

      final again = backend.service();
      await again.load();
      expect(again.outbox, isEmpty);
    });

    test('a failing entry blocks later ones so rows stay in order', () async {
      final backend = FakeBackend();
      final service = backend.service();
      await service.pair('ABCD-EFGH');
      backend.entriesStatus = 503;
      await service.pushEntry({'n': '1'});
      await service.pushEntry({'n': '2'});
      // One attempt per flush for the blocked integration.
      expect(backend.pushTokens, hasLength(2));
      expect(backend.received, isEmpty);
      expect(service.outbox, hasLength(2));
    });

    test('401 marks the integration disconnected; pairing again resumes',
        () async {
      final backend = FakeBackend();
      final service = backend.service();
      await service.pair('ABCD-EFGH');
      backend.entriesStatus = 401;
      await service.pushEntry({'n': '1'});
      expect(service.integrations.single.disconnected, isTrue);
      expect(service.outbox, hasLength(1));

      // Disconnected integrations get no new entries and are not retried.
      await service.pushEntry({'n': '2'});
      await service.flushOutbox();
      expect(service.outbox, hasLength(1));
      expect(backend.pushTokens, hasLength(1));

      final reloaded = backend.service();
      await reloaded.load();
      expect(reloaded.integrations.single.disconnected, isTrue);

      backend.entriesStatus = 200;
      await reloaded.pair('ABCD-EFGH');
      await reloaded.flushOutbox();
      expect(reloaded.integrations.single.disconnected, isFalse);
      expect(reloaded.outbox, isEmpty);
      expect(backend.received.single['data'], {'n': '1'});
      expect(backend.pushTokens.last, 'push-2');
    });

    test('other 4xx drops the entry instead of retrying forever', () async {
      final backend = FakeBackend();
      final service = backend.service();
      await service.pair('ABCD-EFGH');
      backend.entriesStatus = 400;
      await service.pushEntry({'n': '1'});
      expect(service.outbox, isEmpty);
      expect(service.integrations.single.disconnected, isFalse);
    });

    test('removing an integration drops its waiting entries', () async {
      final backend = FakeBackend();
      final service = backend.service();
      await service.pair('ABCD-EFGH');
      backend.entriesStatus = 500;
      await service.pushEntry({'n': '1'});
      await service.remove('int-1');
      expect(service.integrations, isEmpty);
      expect(service.outbox, isEmpty);
    });

    test('concurrent flushes send each entry once', () async {
      final backend = FakeBackend();
      final service = backend.service();
      await service.pair('ABCD-EFGH');
      backend.entriesStatus = 500;
      await service.pushEntry({'n': '1'});
      await service.pushEntry({'n': '2'});
      backend.entriesStatus = 200;
      await Future.wait([
        service.flushOutbox(),
        service.flushOutbox(),
        service.flushOutbox()
      ]);
      expect(backend.received.map((r) => r['data']['n']), ['1', '2']);
    });
  });

  test('generateUuidV4 has version and variant bits', () {
    for (var i = 0; i < 50; i++) {
      final id = IntegrationService.generateUuidV4();
      expect(id, hasLength(36));
      expect(id[14], '4');
      expect('89ab'.contains(id[19]), isTrue);
    }
  });
}
