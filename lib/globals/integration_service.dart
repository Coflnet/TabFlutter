import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// Represents a configured integration on the backend.
class IntegrationConfig {
  final String id;
  final String integrationType;
  final String label;
  final String apiToken;
  final String config;

  IntegrationConfig({
    required this.id,
    required this.integrationType,
    required this.label,
    required this.apiToken,
    this.config = '{}',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'integrationType': integrationType,
        'label': label,
        'apiToken': apiToken,
        'config': config,
      };

  factory IntegrationConfig.fromJson(Map<String, dynamic> json) {
    return IntegrationConfig(
      id: json['id'] ?? '',
      integrationType: json['integrationType'] ?? '',
      label: json['label'] ?? '',
      apiToken: json['apiToken'] ?? '',
      config: json['config'] ?? '{}',
    );
  }
}

/// Service for managing integrations and pushing entries to the backend.
class IntegrationService {
  static final IntegrationService _instance = IntegrationService._internal();
  factory IntegrationService() => _instance;
  IntegrationService._internal();

  static const String _baseUrl = 'https://tab.coflnet.com';

  /// Whether push-to-integrations is enabled.
  bool pushEnabled = false;

  /// Cached list of integrations.
  List<IntegrationConfig> integrations = [];

  /// Load settings from disk.
  Future<void> load() async {
    if (kIsWeb) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/integration_settings.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        pushEnabled = data['pushEnabled'] ?? false;
        integrations = ((data['integrations'] ?? []) as List)
            .map((e) => IntegrationConfig.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('[IntegrationService] Error loading settings: $e');
    }
  }

  /// Save settings to disk.
  Future<void> save() async {
    if (kIsWeb) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/integration_settings.json');
      await file.writeAsString(jsonEncode({
        'pushEnabled': pushEnabled,
        'integrations': integrations.map((i) => i.toJson()).toList(),
      }));
    } catch (e) {
      print('[IntegrationService] Error saving settings: $e');
    }
  }

  /// Create a new integration on the backend and store it locally.
  /// Requires a valid auth token header.
  Future<IntegrationConfig?> createIntegration({
    required String integrationType,
    required String label,
    String config = '{}',
    required String authToken,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/Integration'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'integrationType': integrationType,
          'label': label,
          'config': config,
        }),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        final integration = IntegrationConfig.fromJson(data);
        integrations.add(integration);
        await save();
        return integration;
      } else {
        print(
            '[IntegrationService] Create failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      print('[IntegrationService] Create error: $e');
    }
    return null;
  }

  /// Push entry data to all integrations via the backend.
  Future<bool> pushEntry(Map<String, String> data, {String? authToken}) async {
    if (!pushEnabled || integrations.isEmpty) return false;
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/Integration/push'),
        headers: headers,
        body: jsonEncode({'data': data}),
      );
      if (resp.statusCode == 200) {
        print('[IntegrationService] Entry pushed successfully');
        return true;
      } else {
        print(
            '[IntegrationService] Push failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      print('[IntegrationService] Push error: $e');
    }
    return false;
  }

  /// Fetch integrations from the backend.
  Future<void> fetchIntegrations({required String authToken}) async {
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/api/Integration'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List;
        integrations = list.map((e) => IntegrationConfig.fromJson(e)).toList();
        await save();
      }
    } catch (e) {
      print('[IntegrationService] Fetch error: $e');
    }
  }

  /// Delete an integration.
  Future<void> deleteIntegration(String id, {required String authToken}) async {
    try {
      final resp = await http.delete(
        Uri.parse('$_baseUrl/api/Integration/$id'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (resp.statusCode == 200) {
        integrations.removeWhere((i) => i.id == id);
        await save();
      }
    } catch (e) {
      print('[IntegrationService] Delete error: $e');
    }
  }
}
