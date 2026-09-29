import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/globals/integration_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings → Integrations: connect an Excel workbook (Spables add-in) with
/// the pairing code it shows. Works without an account.
class IntegrationSettingsPage extends StatefulWidget {
  const IntegrationSettingsPage({super.key});

  @override
  State<IntegrationSettingsPage> createState() =>
      _IntegrationSettingsPageState();
}

class _IntegrationSettingsPageState extends State<IntegrationSettingsPage> {
  static const String addInUrl = 'https://app.spables.app/excel/';
  static const Color _accent = Color(0xFF9333EA);
  static const Color _card = Color(0xFF2A2B3D);

  final _service = IntegrationService();
  final _codeController = TextEditingController();
  bool _loading = true;
  bool _pairing = false;
  String? _pairingError;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _service.load();
    if (mounted) setState(() => _loading = false);
    // Retry waiting entries while the user looks at them.
    _service.flushOutbox();
  }

  Future<void> _pair() async {
    if (_pairing) return;
    if (IntegrationService.normalizePairingCode(_codeController.text) == null) {
      setState(() => _pairingError = translate('pairingInvalidCode'));
      return;
    }
    setState(() {
      _pairing = true;
      _pairingError = null;
    });
    try {
      final paired = await _service.pair(_codeController.text);
      _codeController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(translate('pairingSuccess',
                args: {'label': _labelOf(paired)}))));
      }
    } on PairingException catch (e) {
      _pairingError = translate(switch (e.error) {
        PairingError.invalidCode => 'pairingInvalidCode',
        PairingError.notFound => 'pairingNotFound',
        PairingError.rateLimited => 'pairingRateLimited',
        PairingError.network => 'pairingNetwork',
        PairingError.unknown => 'pairingUnknown',
      });
    } catch (_) {
      _pairingError = translate('pairingUnknown');
    }
    if (mounted) setState(() => _pairing = false);
  }

  String _labelOf(PairedIntegration integration) =>
      integration.label.isNotEmpty ? integration.label : 'Excel';

  Future<void> _confirmRemove(PairedIntegration integration) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        content: Text(
          translate('integrationRemoveConfirm',
              args: {'label': _labelOf(integration)}),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(translate('cancel'),
                style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(translate('integrationRemove')),
          ),
        ],
      ),
    );
    if (remove == true) await _service.remove(integration.integrationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1E2B),
      appBar: AppBar(
        title: Text(translate('integrationsTitle')),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildConnectCard(),
                const SizedBox(height: 20),
                Text(
                  translate('connectedIntegrations'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_service.integrations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      translate('noIntegrations'),
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ),
                for (final integration in _service.integrations)
                  _buildIntegrationTile(integration),
              ],
            ),
    );
  }

  Widget _buildConnectCard() {
    const stepStyle = TextStyle(color: Colors.white70, fontSize: 13);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart, color: _accent, size: 20),
              const SizedBox(width: 8),
              Text(
                translate('excelConnect'),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('1. ${translate('excelHowTo1')}', style: stepStyle),
          InkWell(
            onTap: () => launchUrl(Uri.parse(addInUrl),
                mode: LaunchMode.externalApplication),
            child: const Padding(
              padding: EdgeInsets.only(left: 14, top: 2, bottom: 4),
              child: Text(
                addInUrl,
                style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: _accent),
              ),
            ),
          ),
          Text('2. ${translate('excelHowTo2')}', style: stepStyle),
          const SizedBox(height: 2),
          Text('3. ${translate('excelHowTo3')}', style: stepStyle),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  enabled: !_pairing,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLength: 12,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 2,
                      fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: translate('pairingCodeHint'),
                    hintStyle: const TextStyle(
                        color: Colors.white38, fontSize: 14, letterSpacing: 0),
                    counterText: '',
                    errorText: _pairingError,
                    errorMaxLines: 3,
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: _accent)),
                  ),
                  onChanged: (_) {
                    if (_pairingError != null) {
                      setState(() => _pairingError = null);
                    }
                  },
                  onSubmitted: (_) => _pair(),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _accent, foregroundColor: Colors.white),
                  onPressed: _pairing ? null : _pair,
                  child: _pairing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(translate('pairingConnect')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationTile(PairedIntegration integration) {
    final pending = _service.pendingFor(integration.integrationId);
    final status = integration.disconnected
        ? translate('integrationDisconnected')
        : translate('integrationConnected');
    return Card(
      color: _card,
      child: ListTile(
        leading: Icon(
          integration.disconnected ? Icons.link_off : Icons.table_chart,
          color: integration.disconnected ? Colors.redAccent : _accent,
        ),
        title: Text(
          _labelOf(integration),
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: TextStyle(
                  color: integration.disconnected
                      ? Colors.redAccent
                      : Colors.white54,
                  fontSize: 12),
            ),
            if (pending > 0)
              Text(
                translate('integrationPending', args: {'count': pending}),
                style:
                    const TextStyle(color: Colors.orangeAccent, fontSize: 12),
              ),
          ],
        ),
        trailing: IconButton(
          tooltip: translate('integrationRemove'),
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _confirmRemove(integration),
        ),
      ),
    );
  }
}
