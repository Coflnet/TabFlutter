import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// An integration this device is paired with (e.g. an Excel workbook with
/// the Spables add-in). Pairing needs no account: the phone enters the code
/// shown by the add-in and gets a push token for that integration.
class PairedIntegration {
  final String integrationId;
  final String integrationType;
  final String label;
  final String pushToken;

  /// Set when the server answered 401: the token was revoked (e.g. "Handys
  /// trennen" in the add-in). The user has to pair again.
  final bool disconnected;

  const PairedIntegration({
    required this.integrationId,
    required this.integrationType,
    required this.label,
    required this.pushToken,
    this.disconnected = false,
  });

  PairedIntegration copyWith({bool? disconnected}) => PairedIntegration(
        integrationId: integrationId,
        integrationType: integrationType,
        label: label,
        pushToken: pushToken,
        disconnected: disconnected ?? this.disconnected,
      );

  Map<String, dynamic> toJson() => {
        'integrationId': integrationId,
        'integrationType': integrationType,
        'label': label,
        'pushToken': pushToken,
        'disconnected': disconnected,
      };

  static PairedIntegration? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = json['integrationId'];
    final token = json['pushToken'];
    if (id is! String || id.isEmpty || token is! String || token.isEmpty) {
      return null;
    }
    return PairedIntegration(
      integrationId: id,
      integrationType: json['integrationType']?.toString() ?? 'excel',
      label: json['label']?.toString() ?? '',
      pushToken: token,
      disconnected: json['disconnected'] == true,
    );
  }
}

/// One entry waiting to be delivered to one integration.
class OutboxItem {
  final String integrationId;
  final String entryId;
  final Map<String, String> data;
  final DateTime createdAt;

  OutboxItem({
    required this.integrationId,
    required this.entryId,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
        'integrationId': integrationId,
        'entryId': entryId,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
      };

  static OutboxItem? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = json['integrationId'];
    final entryId = json['entryId'];
    final data = json['data'];
    if (id is! String || entryId is! String || data is! Map) return null;
    return OutboxItem(
      integrationId: id,
      entryId: entryId,
      data: data.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

enum PairingError { invalidCode, notFound, rateLimited, network, unknown }

class PairingException implements Exception {
  final PairingError error;
  PairingException(this.error);

  @override
  String toString() => 'PairingException($error)';
}

enum _SendResult { ok, retry, unauthorized, rejected }

/// Pairs this device with integrations and pushes recognized lines to them.
///
/// Every line goes into a persisted outbox first and is removed once the
/// server accepted it, so nothing is lost when the phone is offline or the
/// app is closed. The outbox is retried on app start ([start]), after each
/// recognition and every 60 s.
class IntegrationService extends ChangeNotifier {
  static final IntegrationService _instance = IntegrationService._internal();
  factory IntegrationService() => _instance;
  IntegrationService._internal() : baseUrl = defaultBaseUrl;

  /// A separate instance for tests.
  @visibleForTesting
  IntegrationService.forTesting({http.Client? client, String? baseUrl})
      : _client = client,
        baseUrl = baseUrl ?? defaultBaseUrl;

  static const String defaultBaseUrl = 'https://tab.coflnet.com';
  static const String _integrationsKey = 'paired_integrations_v1';
  static const String _outboxKey = 'integration_outbox_v1';

  /// Entries older than this are dropped; the server keeps them 30 days.
  static const Duration maxOutboxAge = Duration(days: 30);
  static const int maxOutboxItems = 1000;
  static const Duration _requestTimeout = Duration(seconds: 20);

  final String baseUrl;
  http.Client? _client;
  http.Client get _http => _client ??= http.Client();

  List<PairedIntegration> _integrations = [];
  List<OutboxItem> _outbox = [];
  bool _loaded = false;
  Future<void>? _loading;
  Future<void>? _flushing;
  bool _flushRequested = false;
  Timer? _timer;

  List<PairedIntegration> get integrations => List.unmodifiable(_integrations);
  List<OutboxItem> get outbox => List.unmodifiable(_outbox);

  /// Number of entries still waiting for [integrationId].
  int pendingFor(String integrationId) =>
      _outbox.where((i) => i.integrationId == integrationId).length;

  /// Loads, retries the outbox and keeps retrying every 60 s. Call once at
  /// app start.
  Future<void> start() async {
    await load();
    _timer ??= Timer.periodic(const Duration(seconds: 60), (_) {
      if (_outbox.isNotEmpty) flushOutbox();
    });
    await flushOutbox();
  }

  /// Loads paired integrations and the outbox from shared_preferences.
  Future<void> load() {
    if (_loaded) return Future.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _integrations = _decodeList(prefs.getString(_integrationsKey))
          .map(PairedIntegration.fromJson)
          .whereType<PairedIntegration>()
          .toList();
      _outbox = _decodeList(prefs.getString(_outboxKey))
          .map(OutboxItem.fromJson)
          .whereType<OutboxItem>()
          .toList();
    } catch (e) {
      debugPrint('[IntegrationService] Load failed: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  static List<dynamic> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded : const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveIntegrations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_integrationsKey,
          jsonEncode(_integrations.map((i) => i.toJson()).toList()));
    } catch (e) {
      debugPrint('[IntegrationService] Save failed: $e');
    }
  }

  Future<void> _saveOutbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _outboxKey, jsonEncode(_outbox.map((i) => i.toJson()).toList()));
    } catch (e) {
      debugPrint('[IntegrationService] Save failed: $e');
    }
  }

  // ---------------------------------------------------------------- pairing

  static const String pairingAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// Normalizes user input to `XXXX-XXXX`, or returns null when it cannot be
  /// a pairing code. Case, spaces and dashes do not matter.
  static String? normalizePairingCode(String input) {
    final compact = input.toUpperCase().replaceAll(RegExp(r'[\s\-_–—.]'), '');
    if (compact.length != 8) return null;
    for (final ch in compact.split('')) {
      if (!pairingAlphabet.contains(ch)) return null;
    }
    return '${compact.substring(0, 4)}-${compact.substring(4)}';
  }

  /// Pairs with the integration that shows [code]. Throws [PairingException].
  Future<PairedIntegration> pair(String code) async {
    final normalized = normalizePairingCode(code);
    if (normalized == null) throw PairingException(PairingError.invalidCode);
    await load();
    http.Response resp;
    try {
      resp = await _http
          .post(Uri.parse('$baseUrl/api/integration/pair'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'code': normalized}))
          .timeout(_requestTimeout);
    } catch (e) {
      debugPrint('[IntegrationService] Pair network error: $e');
      throw PairingException(PairingError.network);
    }
    if (resp.statusCode == 404) {
      throw PairingException(PairingError.notFound);
    }
    if (resp.statusCode == 400) {
      throw PairingException(PairingError.invalidCode);
    }
    if (resp.statusCode == 429) {
      throw PairingException(PairingError.rateLimited);
    }
    if (resp.statusCode != 200) {
      debugPrint('[IntegrationService] Pair failed: ${resp.statusCode}');
      throw PairingException(
          resp.statusCode >= 500 ? PairingError.network : PairingError.unknown);
    }
    PairedIntegration? paired;
    try {
      paired = PairedIntegration.fromJson(jsonDecode(resp.body));
    } catch (_) {}
    if (paired == null) throw PairingException(PairingError.unknown);

    // Pairing the same workbook again replaces the revoked token and lets
    // the entries that waited for it through.
    final id = paired.integrationId;
    final index = _integrations.indexWhere((i) => i.integrationId == id);
    if (index >= 0) {
      _integrations[index] = paired;
    } else {
      _integrations.add(paired);
    }
    await _saveIntegrations();
    notifyListeners();
    unawaited(flushOutbox());
    return paired;
  }

  /// Forgets [integrationId] on this device, including its waiting entries.
  Future<void> remove(String integrationId) async {
    await load();
    _integrations.removeWhere((i) => i.integrationId == integrationId);
    _outbox.removeWhere((i) => i.integrationId == integrationId);
    await _saveIntegrations();
    await _saveOutbox();
    notifyListeners();
  }

  // ---------------------------------------------------------------- pushing

  /// Queues one recognized line for every paired integration and sends it.
  /// The same entryId is used for all integrations; the server dedupes per
  /// entryId, so retries never create duplicate rows.
  Future<void> pushEntry(Map<String, String> data) async {
    await load();
    final targets = _integrations.where((i) => !i.disconnected).toList();
    if (targets.isEmpty) return;
    final entryId = generateUuidV4();
    for (final target in targets) {
      _outbox.add(OutboxItem(
          integrationId: target.integrationId,
          entryId: entryId,
          data: Map.of(data)));
    }
    _trimOutbox();
    await _saveOutbox();
    notifyListeners();
    await flushOutbox();
  }

  void _trimOutbox() {
    final cutoff = DateTime.now().toUtc().subtract(maxOutboxAge);
    _outbox.removeWhere((i) => i.createdAt.isBefore(cutoff));
    if (_outbox.length > maxOutboxItems) {
      _outbox.removeRange(0, _outbox.length - maxOutboxItems);
    }
  }

  /// Sends waiting entries. Concurrent calls share one run; a call during a
  /// run triggers one more pass so newly queued entries are not missed.
  Future<void> flushOutbox() {
    final running = _flushing;
    if (running != null) {
      _flushRequested = true;
      return running;
    }
    final run = _runFlush();
    _flushing = run;
    return run;
  }

  Future<void> _runFlush() async {
    try {
      await load();
      do {
        _flushRequested = false;
        await _flushOnce();
      } while (_flushRequested);
    } finally {
      // Cleared without a gap after the last check, so no request is lost.
      _flushing = null;
    }
  }

  Future<void> _flushOnce() async {
    if (_outbox.isEmpty) return;
    _trimOutbox();
    // An integration whose entry failed in this pass is skipped for the rest
    // of it, so its rows still arrive in order.
    final blocked = <String>{};
    for (final item in List.of(_outbox)) {
      if (blocked.contains(item.integrationId)) continue;
      final integration = _integrations
          .where((i) => i.integrationId == item.integrationId)
          .firstOrNull;
      if (integration == null) {
        _outbox.remove(item);
        await _saveOutbox();
        continue;
      }
      if (integration.disconnected) {
        blocked.add(item.integrationId);
        continue;
      }
      switch (await _send(integration, item)) {
        case _SendResult.ok:
        case _SendResult.rejected:
          _outbox.remove(item);
          await _saveOutbox();
        case _SendResult.retry:
          blocked.add(item.integrationId);
        case _SendResult.unauthorized:
          blocked.add(item.integrationId);
          _markDisconnected(item.integrationId);
          await _saveIntegrations();
      }
    }
    notifyListeners();
  }

  void _markDisconnected(String integrationId) {
    final index =
        _integrations.indexWhere((i) => i.integrationId == integrationId);
    if (index >= 0) {
      _integrations[index] = _integrations[index].copyWith(disconnected: true);
    }
  }

  Future<_SendResult> _send(
      PairedIntegration integration, OutboxItem item) async {
    try {
      final resp = await _http
          .post(Uri.parse('$baseUrl/api/integration/entries'),
              headers: {
                'Content-Type': 'application/json',
                'X-Integration-Push-Token': integration.pushToken,
              },
              body: jsonEncode({'entryId': item.entryId, 'data': item.data}))
          .timeout(_requestTimeout);
      final code = resp.statusCode;
      if (code >= 200 && code < 300) return _SendResult.ok;
      if (code == 401) return _SendResult.unauthorized;
      if (code >= 500 || code == 408 || code == 429) return _SendResult.retry;
      // Other 4xx (e.g. too many columns) fail the same way on every retry.
      debugPrint('[IntegrationService] Entry rejected: $code');
      return _SendResult.rejected;
    } catch (e) {
      debugPrint('[IntegrationService] Push network error: $e');
      return _SendResult.retry;
    }
  }

  // ------------------------------------------------------------------ utils

  /// Random (version 4) UUID, e.g. `0b0f3c9e-6a41-4c55-9b1e-2f6a3d7c8e90`.
  static String generateUuidV4([Random? random]) {
    final rnd = random ?? Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
