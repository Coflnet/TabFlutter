import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

List<col> collumns = [];

class SaveColumn {
  void loadColumns() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDir.path}/savedColumns.json";
    File file = File(filePath);
    if (!file.existsSync()) {
      await createFile(file);
    }

    var fileDataJson = file.readAsStringSync();
    var fileData = jsonDecode(fileDataJson);
    print(fileData);
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
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDir.path}/itemDetails.json";
    File file = File(filePath);
    var fileData = {"columns": collumns};

    var fileDataJson = jsonEncode(fileData);
    file.writeAsString(fileDataJson);
  }

  get getColumns => collumns;
}
