import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/account_service.dart';
import 'package:table_entry/globals/auth_service.dart';
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
  bool _isImmutable = false;
  bool _zeroRetention = false;
  bool _immutableLocked = false; // once enabled, cannot be turned off
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  String _getAuthToken() {
    return AuthService().jwtToken ?? '';
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
        _isImmutable = settings.isImmutable;
        _zeroRetention = settings.zeroRetention;
        _immutableLocked = settings.isImmutable;
      }
    } catch (e) {
      print('[TableSettingsPage] Load error: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      final result = await _accountService.updateTableSettings(
        widget.table.id.toString(),
        storeRecordings10Years: _storeRecordings10Years,
        isImmutable: _isImmutable,
        zeroRetention: _zeroRetention,
        authToken: _getAuthToken(),
      );
      if (mounted) {
        final success = result['success'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Settings saved'
                : result['error'] ?? 'Failed to save settings'),
            backgroundColor: success ? HexColor("#8332AC") : Colors.red,
          ),
        );
        if (success && _isImmutable) {
          setState(() => _immutableLocked = true);
        }
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
              child: ListView(
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
                          onChanged: _zeroRetention
                              ? null
                              : (val) {
                                  setState(() => _storeRecordings10Years = val);
                                },
                          activeColor: HexColor("#8332AC"),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_storeRecordings10Years) ...[
                          const SizedBox(height: 8),
                          _buildInfoBanner(
                            color: Colors.amber,
                            text:
                                'Recordings are encrypted at rest (AES-256-GCM) and stored on EU servers. You can export and delete records per month at any time.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Zero Retention Section
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
                            Icon(Icons.delete_sweep,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Zero Retention',
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
                            'Delete data immediately after processing',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          subtitle: Text(
                            _zeroRetention
                                ? 'Audio recordings and raw data are deleted immediately after transcription. Only the final text entry is kept.'
                                : 'Data is retained according to the default policy.',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                          ),
                          value: _zeroRetention,
                          onChanged: _storeRecordings10Years
                              ? null
                              : (val) {
                                  setState(() => _zeroRetention = val);
                                },
                          activeColor: HexColor("#8332AC"),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_zeroRetention) ...[
                          const SizedBox(height: 8),
                          _buildInfoBanner(
                            color: Colors.orange,
                            text:
                                'Zero retention cannot be combined with 10-year storage. Audio data is irrecoverably deleted after transcription.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Immutability Section
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
                            Icon(Icons.lock, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Immutability',
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
                            'Make entries immutable',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          subtitle: Text(
                            _immutableLocked
                                ? 'Immutability is enabled and cannot be turned off. Entries cannot be edited or deleted.'
                                : _isImmutable
                                    ? 'Once saved, entries in this table cannot be edited or deleted. This cannot be undone!'
                                    : 'Entries can be freely edited and deleted (default).',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                          ),
                          value: _isImmutable,
                          onChanged: _immutableLocked
                              ? null
                              : (val) {
                                  if (val) {
                                    _showImmutabilityWarning();
                                  } else {
                                    setState(() => _isImmutable = false);
                                  }
                                },
                          activeColor: Colors.red[400],
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_isImmutable) ...[
                          const SizedBox(height: 8),
                          _buildInfoBanner(
                            color: Colors.red,
                            text: _immutableLocked
                                ? 'Immutability is permanently enabled on this table for compliance purposes.'
                                : '⚠️ Warning: Once saved, immutability CANNOT be disabled. Entries will be permanently locked.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Requirement notice
                  _buildInfoBanner(
                    color: Colors.blue,
                    text:
                        '10-year storage, zero retention, and immutability require a paid subscription and at least one active integration.',
                  ),

                  const SizedBox(height: 24),
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

  Widget _buildInfoBanner({required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showImmutabilityWarning() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HexColor("#1E1E2E"),
        title: const Text('Enable Immutability?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Once immutability is enabled and saved, it CANNOT be turned off. '
          'All entries in this table will be permanently locked — they cannot '
          'be edited or deleted. This is intended for compliance and audit purposes.\n\n'
          'Are you sure you want to proceed?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _isImmutable = true);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Enable Immutability',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
