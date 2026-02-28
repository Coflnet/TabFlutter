import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/columns/saveColumn.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/globals/recordingService/recordingServer.dart';

class Listeningmodemain extends StatefulWidget {
  const Listeningmodemain({super.key});

  @override
  State<Listeningmodemain> createState() => _ListeningmodemainState();
}

class _ListeningmodemainState extends State<Listeningmodemain>
    with SingleTickerProviderStateMixin {
  String words = "";
  late AnimationController _pulseController;

  /// Tracks which entries are in edit mode, keyed by RecordedEntry identity.
  final Map<RecordedEntry, Map<String, TextEditingController>>
      _editControllers = {};

  /// Tracks which entries have been corrected and can be sent for training.
  final Set<RecordedEntry> _correctedEntries = {};

  /// Tracks entries that have already been sent for training.
  final Set<RecordedEntry> _sentForTraining = {};

  @override
  void initState() {
    super.initState();
    RecordingServer().addListener(_onUpdate);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    RecordingServer().removeListener(_onUpdate);
    _pulseController.dispose();
    for (final controllers in _editControllers.values) {
      for (final c in controllers.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) {
      // Show a snackbar if the recording service reported an error
      final error = RecordingServer().consumeError();
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() {
        words = RecordingServer().getReconizedWords;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final server = RecordingServer();
    final entries = server.sessionEntries;
    final segments = server.processedSegments;
    final columns = SaveColumn().getColumns;

    return Column(
      children: <Widget>[
        const SizedBox(height: 100),
        // Table selector dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: HexColor("23263E"),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF9333EA).withValues(alpha: 0.4)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: columns.isEmpty
                    ? null
                    : (SaveColumn().getSelcColumn < columns.length
                        ? SaveColumn().getSelcColumn
                        : 0),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.white70),
                dropdownColor: HexColor("23263E"),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: columns.isEmpty
                    ? [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text(translate('noTablesAvailable'),
                              style: const TextStyle(fontSize: 16)),
                        )
                      ]
                    : List.generate(columns.length, (i) {
                        final t = columns[i];
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text('${t.emoji} ${t.name}',
                              style: const TextStyle(fontSize: 16)),
                        );
                      }),
                onChanged: (index) {
                  if (index == null || columns.isEmpty) return;
                  setState(() {
                    SaveColumn().setSelcColumn = index;
                    SaveColumn().saveFile();
                    RecentLogHandler().setCurrentSelected = columns[index];
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Status bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Listening indicator
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withValues(
                          alpha: 0.5 + 0.5 * _pulseController.value),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                translate('listening'),
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const Spacer(),
              // Segments processed counter
              Icon(Icons.mic, color: Colors.grey[500], size: 16),
              const SizedBox(width: 4),
              Text(
                '$segments ${translate('processed')}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(width: 12),
              // Entries counter
              Icon(Icons.check_circle,
                  color: entries.isNotEmpty
                      ? const Color(0xFF22C55E)
                      : Colors.grey[600],
                  size: 16),
              const SizedBox(width: 4),
              Text(
                '${entries.length} ${translate('entries')}',
                style: TextStyle(
                  color: entries.isNotEmpty
                      ? const Color(0xFF22C55E)
                      : Colors.grey[500],
                  fontSize: 12,
                  fontWeight:
                      entries.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Current recognized text
        if (words.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HexColor("23263E"),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                words,
                style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
              ),
            ),
          ),
        const SizedBox(height: 8),
        // Recent entries list
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hearing, size: 48, color: Colors.grey[700]),
                      const SizedBox(height: 12),
                      Text(
                        translate('waitingForSpeech'),
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        translate('speakNaturally'),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final recordedEntry = entries[index];
                    final e = recordedEntry.entry;
                    final age =
                        DateTime.now().difference(recordedEntry.createdAt);
                    final ageText = age.inSeconds < 60
                        ? '${age.inSeconds}s ago'
                        : '${age.inMinutes}m ago';
                    final isEditing =
                        _editControllers.containsKey(recordedEntry);
                    final wasCorrected =
                        _correctedEntries.contains(recordedEntry);
                    final wasSent = _sentForTraining.contains(recordedEntry);

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: HexColor("23263E"),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: wasCorrected
                                  ? const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.4)
                                  : const Color(0xFF22C55E)
                                      .withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                    wasCorrected
                                        ? Icons.edit_note
                                        : Icons.check_circle,
                                    color: wasCorrected
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF22C55E),
                                    size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${e.emoji} ${e.name}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                ),
                                Text(
                                  ageText,
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 11),
                                ),
                                const SizedBox(width: 8),
                                // Edit / Save button
                                GestureDetector(
                                  onTap: () => isEditing
                                      ? _saveCorrection(recordedEntry, e)
                                      : _startEditing(recordedEntry, e),
                                  child: Icon(
                                    isEditing ? Icons.check : Icons.edit,
                                    color: isEditing
                                        ? const Color(0xFF22C55E)
                                        : Colors.white54,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Show editable fields or read-only chips
                            if (isEditing)
                              ..._buildEditableFields(recordedEntry, e)
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: e.params
                                    .where((p) =>
                                        p.svalue != null &&
                                        p.svalue.toString().isNotEmpty)
                                    .map((p) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF9333EA)
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${p.name}: ${p.svalue}',
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            // "Send for training" button after correction
                            if (wasCorrected && !wasSent)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () =>
                                        _sendForTraining(recordedEntry, e),
                                    icon: const Icon(Icons.school, size: 16),
                                    label: Text(translate('sendForTraining')),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFF59E0B),
                                      backgroundColor: const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                    ),
                                  ),
                                ),
                              ),
                            if (wasSent)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Color(0xFF22C55E), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      translate('sentForTraining'),
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 75),
      ],
    );
  }

  void _startEditing(RecordedEntry recordedEntry, col entry) {
    final controllers = <String, TextEditingController>{};
    for (final p in entry.params) {
      controllers[p.name] =
          TextEditingController(text: p.svalue?.toString() ?? '');
    }
    setState(() {
      _editControllers[recordedEntry] = controllers;
    });
  }

  void _saveCorrection(RecordedEntry recordedEntry, col entry) {
    final controllers = _editControllers[recordedEntry]!;
    bool changed = false;
    for (final p in entry.params) {
      final newVal = controllers[p.name]?.text ?? '';
      if (newVal != (p.svalue?.toString() ?? '')) {
        p.svalue = newVal;
        changed = true;
      }
    }
    setState(() {
      _editControllers.remove(recordedEntry);
      if (changed) {
        _correctedEntries.add(recordedEntry);
      }
    });
    // Also update the recent log
    RecentLogHandler().saveFile();
  }

  List<Widget> _buildEditableFields(RecordedEntry recordedEntry, col entry) {
    final controllers = _editControllers[recordedEntry]!;
    return entry.params
        .where((p) => controllers.containsKey(p.name))
        .map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: TextField(
                controller: controllers[p.name],
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: p.name,
                  labelStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                        color: const Color(0xFF9333EA).withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFF9333EA)),
                  ),
                ),
              ),
            ))
        .toList();
  }

  Future<void> _sendForTraining(RecordedEntry recordedEntry, col entry) async {
    // Show confirmation dialog with privacy policy link
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HexColor("1D1E2B"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          translate('sendForTrainingTitle'),
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate('sendForTrainingBody'),
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // Open privacy policy in browser
                // ignore: deprecated_member_use
                launchUrl(Uri.parse('https://spables.app/privacy'));
              },
              child: Text(
                translate('sendForTrainingPrivacy'),
                style: const TextStyle(
                  color: Color(0xFF9333EA),
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF9333EA),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(translate('cancel'),
                style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(translate('confirm')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final correctedData = entry.params
          .where((p) => p.svalue != null && p.svalue.toString().isNotEmpty)
          .map((p) => '${p.name}: ${p.svalue}')
          .join(', ');
      final initialColumnsStr = recordedEntry.initialColumns.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');

      final response = await http.post(
        Uri.parse('https://tab.coflnet.com/api/dialect/report-training-data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': 'training-correction',
          'appVersion': '0.0.4+7',
          'state': 'correction',
          'message': 'User corrected entry for training',
          'log': 'Table: ${entry.name} | Corrected fields: $correctedData',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'audioIds': recordedEntry.audioIds,
          'initialTranscription': recordedEntry.initialTranscription,
          'initialColumns': 'Table: ${entry.name} | $initialColumnsStr',
          'correctedColumns': 'Table: ${entry.name} | $correctedData',
        }),
      );

      if (response.statusCode >= 400) {
        throw Exception(
            'Failed to send training data: ${response.statusCode} ${response.body}');
      }

      setState(() {
        _sentForTraining.add(recordedEntry);
      });
    } catch (e) {
      debugPrint('Failed to send training data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${translate("error")}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
