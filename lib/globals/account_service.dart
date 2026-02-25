import 'dart:convert';
import 'package:http/http.dart' as http;

/// Represents a data export record from the backend.
class DataExportInfo {
  final String id;
  final String status;
  final String exportType;
  final String? month;
  final String createdAt;
  final String? expiresAt;
  final String? downloadUrl;
  final String? message;

  DataExportInfo({
    required this.id,
    required this.status,
    required this.exportType,
    this.month,
    required this.createdAt,
    this.expiresAt,
    this.downloadUrl,
    this.message,
  });

  factory DataExportInfo.fromJson(Map<String, dynamic> json) {
    return DataExportInfo(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      exportType: json['exportType'] ?? '',
      month: json['month'],
      createdAt: json['createdAt'] ?? '',
      expiresAt: json['expiresAt'],
      downloadUrl: json['downloadUrl'],
      message: json['message'],
    );
  }
}

/// Represents per-table settings from the backend.
class TableSettingsInfo {
  final String tableId;
  final bool storeRecordings10Years;

  TableSettingsInfo({
    required this.tableId,
    required this.storeRecordings10Years,
  });

  factory TableSettingsInfo.fromJson(Map<String, dynamic> json) {
    return TableSettingsInfo(
      tableId: json['tableId'] ?? '',
      storeRecordings10Years: json['storeRecordings10Years'] ?? false,
    );
  }
}

/// Service for account management: deletion, data export, table settings.
class AccountService {
  static final AccountService _instance = AccountService._internal();
  factory AccountService() => _instance;
  AccountService._internal();

  static const String _baseUrl = 'https://tab.coflnet.com';

  // ── Table Settings ─────────────────────────────────────────────────

  /// Get settings for a specific table.
  Future<TableSettingsInfo?> getTableSettings(String tableId,
      {required String authToken}) async {
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/api/Account/table-settings/$tableId'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (resp.statusCode == 200) {
        return TableSettingsInfo.fromJson(jsonDecode(resp.body));
      }
    } catch (e) {
      print('[AccountService] getTableSettings error: $e');
    }
    return null;
  }

  /// Update settings for a specific table.
  Future<bool> updateTableSettings(String tableId,
      {required bool storeRecordings10Years, required String authToken}) async {
    try {
      final resp = await http.put(
        Uri.parse('$_baseUrl/api/Account/table-settings/$tableId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'storeRecordings10Years': storeRecordings10Years}),
      );
      return resp.statusCode == 200;
    } catch (e) {
      print('[AccountService] updateTableSettings error: $e');
    }
    return false;
  }

  // ── Data Export ────────────────────────────────────────────────────

  /// Request a full data export (limited to 2/month).
  Future<DataExportInfo?> requestFullExport({required String authToken}) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/Account/export'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (resp.statusCode == 200) {
        return DataExportInfo.fromJson(jsonDecode(resp.body));
      } else {
        final error = jsonDecode(resp.body);
        throw Exception(error['error'] ?? 'Export request failed');
      }
    } catch (e) {
      print('[AccountService] requestFullExport error: $e');
      rethrow;
    }
  }

  /// Request a monthly export for archival. Month format: YYYY-MM.
  Future<DataExportInfo?> requestMonthlyExport(String month,
      {required String authToken}) async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/Account/export/monthly'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'month': month}),
      );
      if (resp.statusCode == 200) {
        return DataExportInfo.fromJson(jsonDecode(resp.body));
      } else {
        final error = jsonDecode(resp.body);
        throw Exception(error['error'] ?? 'Monthly export request failed');
      }
    } catch (e) {
      print('[AccountService] requestMonthlyExport error: $e');
      rethrow;
    }
  }

  /// Delete records for a specific month. Month format: YYYY-MM.
  Future<int> deleteRecordsForMonth(String month,
      {required String authToken}) async {
    try {
      final resp = await http.delete(
        Uri.parse('$_baseUrl/api/Account/records/$month'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['deletedCount'] ?? 0;
      } else {
        final error = jsonDecode(resp.body);
        throw Exception(error['error'] ?? 'Delete failed');
      }
    } catch (e) {
      print('[AccountService] deleteRecordsForMonth error: $e');
      rethrow;
    }
  }

  /// List all exports for the current user.
  Future<List<DataExportInfo>> listExports({required String authToken}) async {
    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/api/Account/exports'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List;
        return list.map((e) => DataExportInfo.fromJson(e)).toList();
      }
    } catch (e) {
      print('[AccountService] listExports error: $e');
    }
    return [];
  }

  // ── Account Deletion ──────────────────────────────────────────────

  /// Delete the user's account. Returns the export info with download details.
  Future<DataExportInfo?> deleteAccount({required String authToken}) async {
    try {
      final resp = await http.delete(
        Uri.parse('$_baseUrl/api/Account/account'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (resp.statusCode == 200) {
        return DataExportInfo.fromJson(jsonDecode(resp.body));
      }
    } catch (e) {
      print('[AccountService] deleteAccount error: $e');
      rethrow;
    }
    return null;
  }
}
