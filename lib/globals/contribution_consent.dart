import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Purpose-based consent for sending corrections as training data, using the
/// shared backend flow (/api/dialect/consents). Works without an account: a
/// random device key proves ownership of the receipt and allows withdrawal.
class ContributionConsent {
  static const baseUrl = 'https://tab.coflnet.com/api/dialect/consents';
  static const keyHeader = 'X-Contribution-Key';

  /// Coflnet speech-to-text training (purpose bit 4 of the backend notice).
  static const trainingPurpose = 4;

  static const _storage = FlutterSecureStorage();
  static const _deviceKeyName = 'contribution_device_key_v1';
  static const _receiptName = 'training_consent_receipt_v1';

  static Future<String> deviceKey() async {
    var key = await _storage.read(key: _deviceKeyName);
    if (key == null) {
      final random = Random.secure();
      key = List.generate(
              32, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
          .join();
      await _storage.write(key: _deviceKeyName, value: key);
    }
    return key;
  }

  static Future<Map<String, String>> headers() async => {
        'Content-Type': 'application/json',
        keyHeader: await deviceKey(),
      };

  /// The server-owned, versioned notice (information, terms, purposes).
  static Future<Map<String, dynamic>> notice() async {
    final response = await http.get(Uri.parse('$baseUrl/notice'));
    _check(response);
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  /// Receipt id if this device holds a training consent that is still active
  /// under the current notice; null otherwise (e.g. withdrawn or re-worded).
  static Future<String?> activeReceipt() async {
    final id = await _storage.read(key: _receiptName);
    if (id == null) return null;
    final response =
        await http.get(Uri.parse('$baseUrl/$id'), headers: await headers());
    if (response.statusCode == 401) return null;
    _check(response);
    final purposes = (jsonDecode(response.body) as Map)['purposes'] as int;
    return purposes & trainingPurpose != 0 ? id : null;
  }

  static Future<bool> hasReceipt() async =>
      await _storage.read(key: _receiptName) != null;

  static Future<String> grant(String noticeVersion) async {
    final response = await http.post(Uri.parse(baseUrl),
        headers: await headers(),
        body: jsonEncode({
          'purposes': trainingPurpose,
          'version': noticeVersion,
          'acceptTerms': true,
        }));
    _check(response);
    final id = (jsonDecode(response.body) as Map)['id'] as String;
    await _storage.write(key: _receiptName, value: id);
    return id;
  }

  /// Withdraws the training consent; the backend deletes the stored data.
  static Future<void> withdraw() async {
    final id = await _storage.read(key: _receiptName);
    if (id == null) return;
    final response = await http.post(Uri.parse('$baseUrl/$id/withdraw'),
        headers: await headers(),
        body: jsonEncode({'purposes': trainingPurpose}));
    if (response.statusCode != 401) _check(response);
    await _storage.delete(key: _receiptName);
  }

  static void _check(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception(
          '${response.statusCode} ${utf8.decode(response.bodyBytes)}');
    }
  }
}
