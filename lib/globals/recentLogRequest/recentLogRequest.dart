import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';


import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/generatedCode/api.dart';
import 'package:table_entry/globals/auth_service.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/globals/weatherService.dart';
import 'package:table_entry/globals/integration_service.dart';

import '../recordingService/recordingServer.dart';

List weatherCache = [];

class RecentLogRequest {
  static var sessionUuId = generateUuid();

  static String generateUuid() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(1000000);
    return '${now}_$rand';
  }

  /*
  Future<List<col>> request(String inputText, col collumn) async {
    Map<String, PropertyInfo> inputData = convertColumns(collumn);

    final client = ApiClient(basePath: "https://tab.coflnet.com");
    final result = await TabApi(client).post(
        tabRequest: TabRequest(
            requiredColums: [],
            text: inputText,
            columnWithDescription: inputData));
    if (result == null) {
      throw Exception("result in recent log request is null");
    }
    print("InputData: $inputText \n Request Result: $result");
    List<col> newCollumns = addNewEntry(result, collumn);

    return newCollumns;
  }
  */

  /// Reset the session UUID so the server starts a fresh recognition session.
  static void resetSession() {
    sessionUuId = generateUuid();
  }

  Future requestWithAudio(String? audioData, col collumn) async {
    var currentText = RecordingServer().getReconizedWords;
    if (!currentText.endsWith("...")) {
      RecordingServer().setText("$currentText...");
    }
    // A restart during retries must not move this audio into the new session.
    final session = sessionUuId;
    Map<String, PropertyInfo> inputData = convertColumns(collumn);
    final locale = ui.PlatformDispatcher.instance.locale.toLanguageTag();
    final client = ApiClient(basePath: "https://tab.coflnet.com");
    final jwt = AuthService().jwtToken;
    if (jwt != null && jwt.isNotEmpty) {
      client.addDefaultHeader('Authorization', 'Bearer $jwt');
    }
    RecognitionResponse? result;
    for (var attempt = 1;; attempt++) {
      try {
        result = await TabApi(client)
            .recognize(
                recognitionRequest: RecognitionRequest(
                    base64Opus: audioData,
                    language: locale,
                    sessionId: session,
                    columnWithDescription: inputData))
            .timeout(const Duration(seconds: 45));
        break;
      } catch (e) {
        // Retry only what can succeed on a second try (network, timeout,
        // server errors); client errors fail the same way every time.
        final transient = e is TimeoutException ||
            (e is ApiException && (e.code >= 500 || e.innerException != null));
        if (!transient || attempt >= 4) {
          print('Recognize failed: $e');
          // Never leave "..." on screen forever.
          RecordingServer().setText(currentText);
          RecordingServer().reportError(translate('recognitionFailed'));
          return;
        }
        await Future.delayed(
            Duration(milliseconds: 300 * (1 << (attempt - 1))));
      }
    }
    if (result == null) {
      RecordingServer().setText(currentText);
      return;
    }
    try {
      print("Request Result: $result");
    } catch (e) {
      print("Could not log response, something null");
    }
    RecordingServer().setText(result.text ?? "");
    if (result.columnWithText == null || !(result.isComplete ?? false)) {
      return;
    }
    addNewEntry(result.columnWithText!, collumn,
        audioIds: result.audioIds ?? [], initialTranscription: result.text);
  }

  Map<String, PropertyInfo> convertColumns(col collumn) {
    Map<String, PropertyInfo> inputData = {};

    for (var i in collumn.params) {
      if (checkType(i)) continue;
      inputData[i.name] =
          PropertyInfo(type: matchType(i.type), enumValues: i.listOption);
    }
    return inputData;
  }

  List<col> addNewEntry(List<Map<String, String>> result, col collumn,
      {List<String> audioIds = const [], String? initialTranscription}) {
    List<col> newCollumns = [];
    for (var object in result) {
      col newCollumn = collumn.copy();
      object.forEach((String colKey, k) {
        for (var key in newCollumn.params) {
          if (key.name == colKey) {
            print("setting value to $k");
            key["value"] = k;
          }
        }
      });
      newCollumn.createdDate = DateTime.now();
      newCollumn.id =
          RecentLogHandler().getRecentLog.length + 1 + newCollumns.length;
      newCollumns.add(newCollumn);

      // Push to integrations (fire-and-forget)
      _pushToIntegrations(object);
    }
    if (newCollumns.isEmpty) {
      print("addNewEntry: no entries to add (result was empty)");
      return newCollumns;
    }
    print("new collumn values ${newCollumns[0].toString()}");
    RecentLogHandler().addRecentLog(newCollumns);
    // Notify the recording UI about the new entries
    for (var entry in newCollumns) {
      // Capture initial column values before any user edits
      final initialCols = <String, String>{};
      for (var p in entry.params) {
        if (p.svalue != null && p.svalue.toString().isNotEmpty) {
          initialCols[p.name] = p.svalue.toString();
        }
      }
      RecordingServer().addSessionEntry(
        entry,
        audioIds: audioIds,
        initialTranscription: initialTranscription,
        initialColumns: initialCols,
      );
    }
    return newCollumns;
  }

  /// Push entry data to all configured integrations via TabApi.
  void _pushToIntegrations(Map<String, String> data) async {
    try {
      final service = IntegrationService();
      await service.load();
      if (service.pushEnabled && service.integrations.isNotEmpty) {
        await service.pushEntry(data);
        print("[Integrations] Entry pushed to integrations");
      }
    } catch (e) {
      print("[Integrations] Push error: $e");
    }
  }
}

bool checkType(param i) {
  if (i.type == translate("date")) {
    i.svalue = DateTime.now().toIso8601String();
    return true;
  }
  if (i.type == translate("weather")) {
    if (weatherCache.isEmpty) {
      getWeatherData(i);
      return true;
    }
    i.svalue = weatherCache;
    return true;
  }
  return false;
}

void getWeatherData(param i) async {
  final List<dynamic> weatherResult = await WeatherService().getCityName();
  if (weatherResult.isEmpty) {
    i.svalue = ["ERROR", "PERMS DENIED", "CONTACT SUPPORT!"];
    return;
  }
  i.svalue = weatherResult;
  weatherCache = weatherResult;
}

FunctionObjectTypes matchType(String type) {
  switch (type) {
    case "String":
      return FunctionObjectTypes.string;
    case "List":
      return FunctionObjectTypes.string;
    case "Number":
      return FunctionObjectTypes.integer;
    default:
      print("default");
      return FunctionObjectTypes.string;
  }
}
