import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recordingService/recordingServer.dart';

List<col> collumns = [];
bool usedBefore = false;
String language = "en";
int selectedColumn = 0;
late RecordingServer recordingServerREF;

class SaveColumn {
  Future<void> loadColumns() async {
    if (kIsWeb) return;
    if (collumns.isNotEmpty) {
      return;
    }
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDir.path}/savedColumn.json";
    File file = File(filePath);
    if (!file.existsSync()) {
      await createFile(file);
      return;
    }

    var fileDataJson = file.readAsStringSync();
    var fileData = jsonDecode(fileDataJson);
    for (var element in fileData["columns"]) {
      collumns.add(col.fromJson(element));
    }

    usedBefore = fileData["usedBefore"];
    language = fileData["language"];
    selectedColumn = fileData["selectedColumn"];
  }

  Future<void> createFile(file) async {
    file.createSync();
    var fileData = {
      "columns": [],
      "usedBefore": false,
      "language": "en",
      "selectedColumn": 0
    };
    print("creating file \n \n \n \n \n \n");
    saveColumn(
        0,
        col(id: 1, name: "Adress", emoji: "⚙️", params: [
          param(name: "Street", type: translate("optionString")),
          param(name: "Number", type: 'translate("optionString")'),
          param(name: "City", type: 'translate("optionString")'),
          param(name: "ZipCode", type: 'translate("optionString")')
        ]));
    var jsonFileData = jsonEncode(fileData);
    await file.writeAsString(jsonFileData);
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
    if (kIsWeb) return;
    List savingColumns = [];
    Directory appDir = await getApplicationDocumentsDirectory();
    for (var i in collumns) {
      savingColumns.add(i.toJson());
    }
    String filePath = "${appDir.path}/savedColumn.json";
    File file = File(filePath);
    var fileData = {
      "columns": savingColumns,
      "usedBefore": usedBefore,
      "language": language,
      "selectedColumn": selectedColumn
    };

    var fileDataJson = jsonEncode(fileData);
    file.writeAsString(fileDataJson);
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
