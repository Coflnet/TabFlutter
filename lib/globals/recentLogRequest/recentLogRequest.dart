import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:table_entry/generatedCode/api.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';

class RecentLogRequest {
  Future<col> request(String inputText, col collumn) async {
    Map<String, PropertyInfo> inputData = {};
    collumn.params.forEach((i) => inputData[i.name] = PropertyInfo(
          type: FunctionObjectTypes.string,
        ));
    final client = ApiClient(basePath: "https://demo.coflnet.com");
    final result = await TabApi(client).post(
        tabRequest: TabRequest(
            requiredColums: [],
            text: inputText,
            columnWithDescription: inputData));
    if (result == null) {
      throw Exception("result in recent log request is null");
    }

    col newCollumn = collumn;
    result[0].forEach((String colKey, k) {
      collumn.params.forEach((key) {
        if (key.name == colKey) {
          key["value"] = colKey;
        }
      });
    });
    RecentLogHandler().addRecentLog(newCollumn);
    return newCollumn;
  }
}
