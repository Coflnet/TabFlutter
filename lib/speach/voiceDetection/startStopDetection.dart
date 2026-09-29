import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogRequest.dart';
import 'package:table_entry/globals/recordingService/recordingServer.dart';
import 'package:table_entry/globals/recordingService/recordService.dart';
import 'package:table_entry/globals/speachSettingsGlobal.dart';
import 'package:table_entry/pages/main/recentLog/recentLog.dart';
import 'package:table_entry/speach/voiceDetection/startStopDetectionRunning.dart';

class StartStopDetection extends StatefulWidget {
  /// Called with the new recording state (explicit, not a toggle).
  final void Function(bool recording) startStop;
  final Function(String) changeRecordingData;
  const StartStopDetection(
      {super.key, required this.startStop, required this.changeRecordingData});

  @override
  _StartStopDetectionState createState() => _StartStopDetectionState();
}

class _StartStopDetectionState extends State<StartStopDetection>
    with SingleTickerProviderStateMixin {
  double level = 0.0;
  late AnimationController controller;
  bool isRunning = false;
  Alignment alignment = Alignment.bottomRight;
  String recordedData = "";
  String displayedRecordedData = "";
  bool levelIsZero = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
    );
    initSpeach();
    RecordService.instance
        .addRecordStatusChangedCallback(_onRecordStatusChanged);
  }

  @override
  void dispose() {
    RecordService.instance
        .removeRecordStatusChangedCallback(_onRecordStatusChanged);
    controller.dispose();
    super.dispose();
  }

  void _onRecordStatusChanged(RecordStatus status) {
    if (status == RecordStatus.stopped && isRunning) {
      if (mounted) {
        setState(() {
          isRunning = false;
          alignment = Alignment.bottomRight;
        });
        widget.startStop(false);
      }
    }
  }

  void initSpeach() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: alignment,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutQuad,
      child: AnimatedContainer(
        curve: Curves.easeInOutQuad,
        duration: const Duration(milliseconds: 500),
        margin: isRunning
            ? const EdgeInsets.only(bottom: 15)
            : const EdgeInsets.only(bottom: 86),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return isRunning
                ? StartStopDetectionRunning(
                    startStop: startStopListening, run: levelIsZero)
                : TextButton(
                    onPressed: startStopListening,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: HexColor("#8332AC"),
                          borderRadius: BorderRadius.circular(16)),
                      child: Icon(
                        Icons.mic,
                        color: isRunning ? Colors.white : Colors.white70,
                        size: 40,
                      ),
                    ));
          },
        ),
      ),
    );
  }

  /// Ignores taps while a stop is still being processed; tapping start again
  /// during a stop used to leave an orphaned recording service behind. A stop
  /// during start (e.g. while the model loads) is allowed and cancels it.
  bool _busy = false;

  void startStopListening() async {
    if (_busy) return;
    setState(() {
      isRunning = !isRunning;
    });
    widget.startStop(isRunning);

    if (!isRunning) {
      setState(() {
        alignment = Alignment.bottomRight;
      });
      _busy = true;
      try {
        await RecordingServer().stopRecorder();
      } catch (e) {
        print('Error stopping recording: $e');
      }
      _busy = false;
      // Flush the last unfinished entry; failures are reported by the request.
      await RecentLogRequest()
          .requestWithAudio(null, RecentLogHandler().getCurrentSelected);
      if (mounted) {
        Provider.of<UpdateRecentLog>(context, listen: false).recentLogUpdate();
      }

      return;
    }

    setState(() {
      recordedData = "";
      displayedRecordedData = "";
      widget.changeRecordingData(displayedRecordedData);
    });
    startListening();

    try {
      await RecordingServer().startStreaming();
    } catch (e) {
      print('Error starting recording: $e');
      // Revert UI state on failure. The stopped-status callback may already
      // have done so; reverting twice used to leave the UI inverted.
      if (mounted) {
        if (isRunning) {
          setState(() {
            isRunning = false;
            alignment = Alignment.bottomRight;
          });
          widget.startStop(false);
        }
        _showMicrophoneErrorDialog(e.toString());
      }
    }
  }

  void _showMicrophoneErrorDialog(String error) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: HexColor("#2A2B3D"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.mic_off, color: Colors.redAccent, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  translate('micErrorTitle'),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate('micErrorDescription'),
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 16),
              Text(
                translate('micErrorInstructions'),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              const SizedBox(height: 8),
              _instructionRow(Icons.usb, translate('micErrorStep1')),
              _instructionRow(Icons.refresh, translate('micErrorStep2')),
              _instructionRow(Icons.settings, translate('micErrorStep3')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                translate('confirm'),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _instructionRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void startListening() {
    setState(() {
      alignment = Alignment.bottomCenter;
    });
  }

  void soundLevelListener(double level) {
    SpeachSettingsRetrevial().setMinSoundLevel =
        min(SpeachSettingsRetrevial().getMinSoundLevel as double, level);
    SpeachSettingsRetrevial().setMaxSoundLevel =
        min(SpeachSettingsRetrevial().getMaxSoundLevel as double, level);
    setState(() {
      this.level = level;
    });
    if (level == 0) {
      setState(() {
        levelIsZero = true;
      });
    }
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }
}
