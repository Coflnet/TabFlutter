import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

col currentSelected = col(name: "no-tabls", emoji: "", id: 1, params: []);

List<col> recentLog = [];
List<col> displayedLog = [];

class RecentLogHandler {
  Future<void> loadRecentLog() async {
    if (recentLog.isNotEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final fileDataJson = prefs.getString('recentLogData');

    if (fileDataJson == null) {
      return;
    }

    try {
      var fileData = jsonDecode(fileDataJson);
      var columnsData = fileData["columns"] ?? fileData["recentLog"] ?? [];
      for (var element in columnsData) {
        recentLog.add(col.fromJson(element));
      }
      var displayedData = fileData["displayed"] ?? [];
      for (var element in displayedData) {
        displayedLog.add(col.fromJson(element));
      }
    } catch (e) {
      print('Error loading recent log: $e');
    }
  }

  void addRecentLog(List<col> recentLogCol) {
    recentLog.addAll(recentLogCol);
    displayedLog.addAll(recentLogCol);
    saveFile();
  }

  void saveFile() async {
    List savingColumnsAll = [];
    List savingColumnsDisplayed = [];

    for (var i in recentLog) {
      savingColumnsAll.add(i.toJson());
    }
    for (var i in displayedLog) {
      savingColumnsDisplayed.add(i.toJson());
    }

    var fileData = {
      "columns": savingColumnsAll,
      "displayed": savingColumnsDisplayed
    };

    var fileDataJson = jsonEncode(fileData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recentLogData', fileDataJson);
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

  void deleteColumn(col deletingColumn) {
    recentLog.removeWhere((element) => element.id == deletingColumn.id);
    displayedLog.removeWhere((element) => element.id == deletingColumn.id);
    saveFile();
  }

  col get getCurrentSelected => currentSelected;
  set setCurrentSelected(col value) => currentSelected = value;
  List<col> get getRecentLog => recentLog;
  List<col> get getDisplayedLog => displayedLog;
}
