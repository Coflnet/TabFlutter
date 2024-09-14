import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

List<col> collumns = [];

class SaveColumn {
  void loadColumns() async {
    if (collumns.isNotEmpty) {
      return;
    }
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDir.path}/savedColumn.json";
    File file = File(filePath);
    if (!file.existsSync()) {
      await createFile(file);
    }

    var fileDataJson = file.readAsStringSync();
    var fileData = jsonDecode(fileDataJson);
    for (var element in fileData["columns"]) {
      collumns.add(col.fromJson(element));
    }
    print(collumns);
  }

  Future<void> createFile(file) async {
    file.createSync();
    var fileData = {"columns": []};
    var jsonFileData = jsonEncode(fileData);
    await file.writeAsString(jsonFileData);
  }

  void saveColumn(int id, col col) {
    for (var i in collumns) {
      if (i.id == id) {
        collumns.remove(i);
        collumns.add(col);
        saveFile();
        return;
      }
    }
    collumns.add(col);
    saveFile();
  }

  void saveFile() async {
    List savingColumns = [];
    Directory appDir = await getApplicationDocumentsDirectory();
    for (var i in collumns) {
      savingColumns.add(i.toJson());
    }
    String filePath = "${appDir.path}/savedColumn.json";
    File file = File(filePath);
    var fileData = {"columns": savingColumns};

    var fileDataJson = jsonEncode(fileData);
    file.writeAsString(fileDataJson);
  }

  List<col> get getColumns => collumns;
}
