import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

col currentSelected = col(name: "no-tabls", emoji: "", id: 1, params: []);

List<col> recentLog = [];
List<col> displayedLog = [];

class RecentLogHandler {
  Future<void> loadRecentLog() async {
    if (kIsWeb) return;
    if (recentLog.isNotEmpty) {
      return;
    }
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDir.path}/recentLog.json";
    File file = File(filePath);
    if (!file.existsSync()) {
      await createFile(file);
    }

    var fileDataJson = file.readAsStringSync();
    var fileData = jsonDecode(fileDataJson);
    var columnsData = fileData["columns"] ?? fileData["recentLog"] ?? [];
    for (var element in columnsData) {
      recentLog.add(col.fromJson(element));
    }
    var displayedData = fileData["displayed"] ?? [];
    for (var element in displayedData) {
      displayedLog.add(col.fromJson(element));
    }
  }

  void addRecentLog(List<col> recentLogCol) {
    recentLog.addAll(recentLogCol);
    displayedLog.addAll(recentLogCol);
    saveFile();
  }

  void saveFile() async {
    if (kIsWeb) return;
    List savingColumnsAll = [];
    List savingColumnsDisplayed = [];
    Directory appDir = await getApplicationDocumentsDirectory();
    for (var i in recentLog) {
      savingColumnsAll.add(i.toJson());
    }
    for (var i in displayedLog) {
      savingColumnsDisplayed.add(i.toJson());
    }

    String filePath = "${appDir.path}/recentLog.json";
    File file = File(filePath);
    var fileData = {
      "columns": savingColumnsAll,
      "displayed": savingColumnsDisplayed
    };

    var fileDataJson = jsonEncode(fileData);
    file.writeAsString(fileDataJson);
  }

  Future<void> createFile(file) async {
    file.createSync();
    var fileData = {"columns": [], "displayed": []};
    var jsonFileData = jsonEncode(fileData);
    await file.writeAsString(jsonFileData);
  }

  void clear() {
    displayedLog = [];
    saveFile();
  }

  void updateCollumn(col updatingCollumn) {
    for (var i in recentLog) {
      if (i.id == updatingCollumn.id) {
        recentLog.remove(i);
        recentLog.add(updatingCollumn);
        saveFile();
        break;
      }
    }
    for (var i in displayedLog) {
      if (i.id == updatingCollumn.id) {
        displayedLog.remove(i);
        displayedLog.add(updatingCollumn);
        saveFile();
        break;
      }
    }
  }

  col get getCurrentSelected => currentSelected;
  set setCurrentSelected(col value) => currentSelected = value;
  List<col> get getRecentLog => recentLog;
  List<col> get getDisplayedLog => displayedLog;
}
