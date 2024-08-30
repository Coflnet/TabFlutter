import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

bool _hasSpeech = false;
bool _logEvents = false;
bool _onDevice = false;

double minSoundLevel = 50000;
double maxSoundLevel = -50000;
String lastWords = '';
String lastError = '';
String lastStatus = '';
String _currentLocaleId = '';
List<LocaleName> _localeNames = [];

class SpeachSettings {}

class SpeachSettingsRetrevial {
  get get_hasSpeech => _hasSpeech;
  get get_logEvents => _logEvents;
  get get_onDevice => _onDevice;
  get getMinSoundLevel => minSoundLevel;
  get getMaxSoundLevel => maxSoundLevel;
  get getLastWords => lastWords;
  get getLastError => lastError;
  get getLastStatus => lastStatus;
  get getCurrentLocaleId => _currentLocaleId;
  get getLocaleNames => _localeNames;

  set setHasSpeech(value) => {_hasSpeech = value};
  set setLogEvents(value) => {_logEvents = value};
  set setOnDevice(value) => {_onDevice = value};
  set setMinSoundLevel(value) => {minSoundLevel = value};
  set setMaxSoundLevel(value) => {maxSoundLevel = value};
  set setLastWords(value) => {lastWords = value};
  set setLastError(value) => {lastError = value};
  set setLastStatus(value) => {lastStatus = value};
  set setCurrentLocaleId(value) => {_currentLocaleId = value};
}
