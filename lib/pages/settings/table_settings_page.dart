import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/account_service.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

/// A page/dialog for managing per-table settings (e.g., 10-year recording storage).
class TableSettingsPage extends StatefulWidget {
  final col table;

  const TableSettingsPage({Key? key, required this.table}) : super(key: key);

  @override
  State<TableSettingsPage> createState() => _TableSettingsPageState();
}

class _TableSettingsPageState extends State<TableSettingsPage> {
  final AccountService _accountService = AccountService();
  bool _storeRecordings10Years = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  String _getAuthToken() {
    // TODO: Get actual auth token from auth state
    return '';
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      final settings = await _accountService.getTableSettings(
        widget.table.id.toString(),
        authToken: _getAuthToken(),
      );
      if (settings != null) {
        _storeRecordings10Years = settings.storeRecordings10Years;
      }
    } catch (e) {
      print('[TableSettingsPage] Load error: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      final success = await _accountService.updateTableSettings(
        widget.table.id.toString(),
        storeRecordings10Years: _storeRecordings10Years,
        authToken: _getAuthToken(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(success ? 'Settings saved' : 'Failed to save settings'),
            backgroundColor: success ? HexColor("#8332AC") : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#121218"),
      appBar: AppBar(
        backgroundColor: HexColor("#1E1E2E"),
        title: Text(
          '${widget.table.emoji} ${widget.table.name} Settings',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recording Storage Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.mic, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Recording Storage',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text(
                            'Store recordings for 10 years',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          subtitle: Text(
                            _storeRecordings10Years
                                ? 'Audio recordings for entries in this table will be stored for 10 years for compliance/archival purposes.'
                                : 'Audio recordings are only temporarily kept for transcription processing.',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                          ),
                          value: _storeRecordings10Years,
                          onChanged: (val) {
                            setState(() => _storeRecordings10Years = val);
                          },
                          activeColor: HexColor("#8332AC"),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_storeRecordings10Years) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Colors.amber, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Recordings are encrypted at rest (AES-256-GCM) and stored on EU servers. You can export and delete records per month at any time.',
                                    style: TextStyle(
                                        color: Colors.amber[200], fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor("#8332AC"),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Save Settings',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
