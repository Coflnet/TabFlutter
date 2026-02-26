import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recordingService/recordingServer.dart';

List<col> collumns = [];
bool usedBefore = false;
String language = "en";
int selectedColumn = 0;
late RecordingServer recordingServerREF;

class SaveColumn {
  Future<void> loadColumns() async {
    if (collumns.isNotEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final fileDataJson = prefs.getString('savedColumn');

    if (fileDataJson == null) {
      await createFile();
      return;
    }

    var fileData = jsonDecode(fileDataJson);
    for (var element in fileData["columns"]) {
      collumns.add(col.fromJson(element));
    }

    usedBefore = fileData["usedBefore"] ?? false;
    language = fileData["language"] ?? "en";
    selectedColumn = fileData["selectedColumn"] ?? 0;
  }

  Future<void> createFile() async {
    var fileData = {
      "columns": [],
      "usedBefore": false,
      "language": "en",
      "selectedColumn": 0
    };
    print("creating file \n \n \n \n \n \n");

    // Add default sample tables
    collumns.add(col(id: 1, name: "Address", emoji: "🏠", params: [
      param(name: "Street", type: translate("optionString")),
      param(name: "Number", type: translate("optionString")),
      param(name: "City", type: translate("optionString")),
      param(name: "ZipCode", type: translate("optionString"))
    ]));

    collumns.add(col(id: 2, name: "Fahrtenbuch", emoji: "🚗", params: [
      param(name: "Date", type: translate("optionString")),
      param(name: "Start", type: translate("optionString")),
      param(name: "Destination", type: translate("optionString")),
      param(name: "Distance", type: translate("optionString")),
      param(name: "Purpose", type: translate("optionString"))
    ]));

    collumns.add(col(id: 3, name: "Todo/Reminder", emoji: "✅", params: [
      param(name: "Task", type: translate("optionString")),
      param(name: "Due Date", type: translate("optionString")),
      param(name: "Priority", type: translate("optionString"))
    ]));

    saveFile();
  }

  void saveColumn(int id, col col) {
    for (var i in collumns) {
      if (i.id == id) {
        collumns.remove(i);
        collumns.insert(0, col);
        saveFile();
        return;
      }
    }
    collumns.insert(0, col);
    saveFile();
  }

  void deleteColumn(int id) {
    for (var i in collumns) {
      if (i.id == id) {
        collumns.remove(i);
        saveFile();
        return;
      }
    }
  }

  void saveFile() async {
    List savingColumns = [];
    for (var i in collumns) {
      savingColumns.add(i.toJson());
    }

    var fileData = {
      "columns": savingColumns,
      "usedBefore": usedBefore,
      "language": language,
      "selectedColumn": selectedColumn
    };

    var fileDataJson = jsonEncode(fileData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedColumn', fileDataJson);
  }

  bool get getUsedBefore => usedBefore;
  String get getlanguage => language;
  set setUsedBefore(v) => usedBefore = v;
  set setlanguage(v) => language = v;
  List<col> get getColumns => collumns;
  int get getSelcColumn => selectedColumn;
  set setSelcColumn(v) => selectedColumn = v;
  set setRecordingServerREF(v) => recordingServerREF = v;
  RecordingServer get getRecordingServerREF => recordingServerREF;
}
