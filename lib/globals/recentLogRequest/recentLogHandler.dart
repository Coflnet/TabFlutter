import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

late col currentSelected;

List<col> recentLog = [];

class RecentLogHandler {
  void loadRecentLog() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDir.path}/recentLog.json";
    File file = File(filePath);
    if (!file.existsSync()) {
      await createFile(file);
    }

    var fileDataJson = file.readAsStringSync();
    var fileData = jsonDecode(fileDataJson);
    print(fileData);
  }

  void addRecentLog(List<col> recentLogCol) {
    recentLog.addAll(recentLogCol);
    saveFile();
  }

  void saveFile() async {
    List savingColumns = [];
    Directory appDir = await getApplicationDocumentsDirectory();
    for (var i in recentLog) {
      savingColumns.add(i.toJson());
    }
    String filePath = "${appDir.path}/recentLog.json";
    File file = File(filePath);
    var fileData = {"columns": savingColumns};

    var fileDataJson = jsonEncode(fileData);
    file.writeAsString(fileDataJson);
  }

  Future<void> createFile(file) async {
    file.createSync();
    var fileData = {"recentLog": []};
    var jsonFileData = jsonEncode(fileData);
    await file.writeAsString(jsonFileData);
  }

  col get getCurrentSelected => currentSelected;
  set setCurrentSelected(col value) => currentSelected = value;
  List<col> get getRecentLog => recentLog;
}
