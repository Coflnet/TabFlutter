import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceDetection extends StatefulWidget {
  const VoiceDetection({Key? key}) : super(key: key);

  @override
  _VoiceDetectionState createState() => _VoiceDetectionState();
}

class _VoiceDetectionState extends State<VoiceDetection> {
  bool _hasSpeech = false;
  bool _logEvents = false;
  bool _onDevice = false;
  bool turnOff = false;
  final TextEditingController _pauseForController =
      TextEditingController(text: '10');
  final TextEditingController _listenForController =
      TextEditingController(text: '30');
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
  }

  Future<void> initSpeechState() async {
    try {
      var hasSpeech = await speech.initialize(
        debugLogging: _logEvents,
      );
      if (hasSpeech) {
        _localeNames = await speech.locales();

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
