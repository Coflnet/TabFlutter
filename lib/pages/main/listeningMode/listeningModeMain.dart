import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
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
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) {
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
    final currentTable = RecentLogHandler().getCurrentSelected;

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
                value: SaveColumn().getSelcColumn,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.white70),
                dropdownColor: HexColor("23263E"),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: List.generate(columns.length, (i) {
                  final t = columns[i] as col;
                  return DropdownMenuItem<int>(
                    value: i,
                    child: Text('${t.emoji} ${t.name}',
                        style: const TextStyle(fontSize: 16)),
                  );
                }),
                onChanged: (index) {
                  if (index == null) return;
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
                'Listening',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const Spacer(),
              // Segments processed counter
              Icon(Icons.mic, color: Colors.grey[500], size: 16),
              const SizedBox(width: 4),
              Text(
                '$segments processed',
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
                '${entries.length} entries',
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
                        'Waiting for speech…',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Speak naturally. Entries are created automatically.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final e = entry.entry;
                    final age = DateTime.now().difference(entry.createdAt);
                    final ageText = age.inSeconds < 60
                        ? '${age.inSeconds}s ago'
                        : '${age.inMinutes}m ago';

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
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF22C55E), size: 18),
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
                              ],
                            ),
                            const SizedBox(height: 6),
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
}
