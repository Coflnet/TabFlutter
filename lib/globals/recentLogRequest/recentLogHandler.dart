import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

late col currentSelected;

List<col> recentLog = [];
List<col> displayedLog = [];

class RecentLogHandler {
  void loadRecentLog() async {
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
    for (var element in fileData["columns"]) {
      recentLog.add(col.fromJson(element));
    }
    for (var element in fileData["displayed"]) {
      displayedLog.add(col.fromJson(element));
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
    var fileData = {"recentLog": [], "displayed": []};
    var jsonFileData = jsonEncode(fileData);
    await file.writeAsString(jsonFileData);
  }

  void clear() {
    displayedLog = [];
    saveFile();
  }

  col get getCurrentSelected => currentSelected;
  set setCurrentSelected(col value) => currentSelected = value;
  List<col> get getRecentLog => recentLog;
  List<col> get getDisplayedLog => displayedLog;
}
