import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_entry/globals/integration_service.dart';

class IntegrationSettingsPage extends StatefulWidget {
  const IntegrationSettingsPage({super.key});

  @override
  State<IntegrationSettingsPage> createState() =>
      _IntegrationSettingsPageState();
}

class _IntegrationSettingsPageState extends State<IntegrationSettingsPage> {
  final _service = IntegrationService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _service.load();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1E2B),
      appBar: AppBar(
        title: const Text('Integrations'),
        backgroundColor: const Color(0xFF9333EA),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Push toggle
                  SwitchListTile(
                    title: const Text(
                      'Push entries to integrations',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'When enabled, recognized data is pushed to all configured integrations.',
                      style: TextStyle(color: Colors.white54),
                    ),
                    value: _service.pushEnabled,
                    activeColor: const Color(0xFF9333EA),
                    onChanged: (val) {
                      setState(() => _service.pushEnabled = val);
                      _service.save();
                    },
                  ),
                  const Divider(color: Colors.white24),

                  // Integrations list
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Configured Integrations',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: _service.integrations.isEmpty
                        ? const Center(
                            child: Text(
                              'No integrations configured.\nUse the + button to add one.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white38),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _service.integrations.length,
                            itemBuilder: (ctx, i) {
                              final integration = _service.integrations[i];
                              return Card(
                                color: const Color(0xFF2A2B3D),
                                child: ListTile(
                                  leading: Icon(
                                    _iconFor(integration.integrationType),
                                    color: const Color(0xFF9333EA),
                                  ),
                                  title: Text(
                                    integration.label,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        integration.integrationType,
                                        style: const TextStyle(
                                            color: Colors.white54),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: integration.apiToken));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'API token copied!')));
                                        },
                                        child: Text(
                                          'Token: ${integration.apiToken.substring(0, 12)}… (tap to copy)',
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () async {
                                      _service.integrations.removeAt(i);
                                      await _service.save();
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9333EA),
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'excel':
        return Icons.table_chart;
      case 'google_sheets':
        return Icons.grid_on;
      case 'obsidian':
        return Icons.note;
      case 'nextcloud':
        return Icons.cloud;
      case 'proton_docs':
        return Icons.lock;
      default:
        return Icons.extension;
    }
  }

  void _showAddDialog() {
    String selectedType = 'excel';
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2B3D),
        title: const Text('Add Integration',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              dropdownColor: const Color(0xFF2A2B3D),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(
                    value: 'excel', child: Text('Microsoft Excel')),
                DropdownMenuItem(
                    value: 'google_sheets', child: Text('Google Sheets')),
                DropdownMenuItem(value: 'obsidian', child: Text('Obsidian')),
                DropdownMenuItem(value: 'nextcloud', child: Text('Nextcloud')),
                DropdownMenuItem(
                    value: 'proton_docs', child: Text('Proton Docs')),
              ],
              onChanged: (v) => selectedType = v ?? 'excel',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Label',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA)),
            onPressed: () async {
              if (labelController.text.isEmpty) return;
              // Create locally (in a real flow, we'd call the API with auth)
              final integration = IntegrationConfig(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                integrationType: selectedType,
                label: labelController.text,
                apiToken: 'spbl_placeholder_configure_via_api',
              );
              _service.integrations.add(integration);
              await _service.save();
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
