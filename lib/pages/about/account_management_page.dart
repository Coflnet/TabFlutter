import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:table_entry/globals/account_service.dart';
import 'package:table_entry/pages/reusedWidgets/background.dart';
import 'package:table_entry/pages/reusedWidgets/footer/footer.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({Key? key}) : super(key: key);

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final AccountService _accountService = AccountService();
  bool _loading = false;
  List<DataExportInfo> _exports = [];
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadExports();
  }

  Future<void> _loadExports() async {
    setState(() => _loading = true);
    try {
      _exports = await _accountService.listExports(authToken: _getAuthToken());
    } catch (e) {
      // ignore
    }
    setState(() => _loading = false);
  }

  String _getAuthToken() {
    // TODO: Get actual auth token from auth state
    return '';
  }

  Future<void> _requestFullExport() async {
    setState(() => _loading = true);
    try {
      final export =
          await _accountService.requestFullExport(authToken: _getAuthToken());
      if (export != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export requested. Status: ${export.status}'),
            backgroundColor: HexColor("#8332AC"),
          ),
        );
        await _loadExports();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _requestMonthlyExport(String month) async {
    setState(() => _loading = true);
    try {
      final export = await _accountService.requestMonthlyExport(month,
          authToken: _getAuthToken());
      if (export != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Monthly export for $month requested.'),
            backgroundColor: HexColor("#8332AC"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _deleteRecordsForMonth(String month) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HexColor("#1E1E2E"),
        title:
            const Text('Delete Records', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete all records for $month?\n\nThis action cannot be undone. Consider exporting the data first.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      final count = await _accountService.deleteRecordsForMonth(month,
          authToken: _getAuthToken());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted $count records for $month.'),
            backgroundColor: HexColor("#8332AC"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HexColor("#1E1E2E"),
        title:
            const Text('Delete Account', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete your account?\n\n'
          '• A full data export will be created (available for 30 days)\n'
          '• A download link will be sent to your email\n'
          '• All your data will be permanently deleted\n\n'
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Account',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Second confirmation
    final reconfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HexColor("#1E1E2E"),
        title: const Text('Final Confirmation',
            style: TextStyle(color: Colors.red)),
        content: const Text(
          'This will permanently delete your account and all data. Are you absolutely sure?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Account',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE EVERYTHING',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (reconfirmed != true) return;

    setState(() => _loading = true);
    try {
      final export =
          await _accountService.deleteAccount(authToken: _getAuthToken());
      if (mounted && export != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(export.message ??
                'Account deleted. Export available for 30 days.'),
            backgroundColor: HexColor("#8332AC"),
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _loading = false);
  }

  List<String> _getMonthOptions() {
    final now = DateTime.now();
    final months = <String>[];
    for (var i = 0; i < 24; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add('${date.year}-${date.month.toString().padLeft(2, '0')}');
    }
    return months;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Account & Data',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              // Data Export Section
                              _sectionHeader('Data Export', Icons.download),
                              const SizedBox(height: 8),
                              _infoCard(
                                'Full Data Export',
                                'Download all your data (encrypted). Available for 30 days.\nLimited to 2 exports per month.',
                                'Request Export',
                                _requestFullExport,
                              ),
                              const SizedBox(height: 16),

                              // Monthly Export Section
                              _sectionHeader(
                                  'Monthly Archive', Icons.calendar_month),
                              const SizedBox(height: 8),
                              _monthSelector(),
                              if (_selectedMonth != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _actionButton(
                                        'Export $_selectedMonth',
                                        Icons.download,
                                        HexColor("#8332AC"),
                                        () => _requestMonthlyExport(
                                            _selectedMonth!),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _actionButton(
                                        'Delete $_selectedMonth',
                                        Icons.delete_outline,
                                        Colors.red.shade700,
                                        () => _deleteRecordsForMonth(
                                            _selectedMonth!),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 24),

                              // Export History
                              if (_exports.isNotEmpty) ...[
                                _sectionHeader('Export History', Icons.history),
                                const SizedBox(height: 8),
                                ..._exports.map((e) => _exportCard(e)),
                                const SizedBox(height: 24),
                              ],

                              // Danger Zone
                              _sectionHeader('Danger Zone', Icons.warning_amber,
                                  color: Colors.red),
                              const SizedBox(height: 8),
                              _infoCard(
                                'Delete Account',
                                'Permanently delete your account.\n'
                                    'A full data export will be created and a download link sent to your email (30-day TTL).',
                                'Delete Account',
                                _deleteAccount,
                                isDestructive: true,
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon,
      {Color color = Colors.white}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _infoCard(String title, String description, String buttonLabel,
      VoidCallback onPressed,
      {bool isDestructive = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: isDestructive
            ? Border.all(color: Colors.red.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(description,
              style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDestructive ? Colors.red.shade700 : HexColor("#8332AC"),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(buttonLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthSelector() {
    final months = _getMonthOptions();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedMonth,
        hint:
            const Text('Select month...', style: TextStyle(color: Colors.grey)),
        dropdownColor: HexColor("#1E1E2E"),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.expand_more, color: Colors.white),
        items: months
            .map((m) => DropdownMenuItem(
                value: m,
                child: Text(m, style: const TextStyle(color: Colors.white))))
            .toList(),
        onChanged: (val) => setState(() => _selectedMonth = val),
      ),
    );
  }

  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  Widget _exportCard(DataExportInfo export) {
    Color statusColor;
    switch (export.status) {
      case 'ready':
        statusColor = Colors.green;
        break;
      case 'processing':
        statusColor = Colors.orange;
        break;
      case 'failed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${export.exportType.toUpperCase()}${export.month != null ? ' (${export.month})' : ''}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  export.createdAt.substring(0, 10),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(export.status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
