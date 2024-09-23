import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:table_entry/generatedCode/api.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';

class RecentLogRequest {
  Future<List<col>> request(String inputText, col collumn) async {
    Map<String, PropertyInfo> inputData = {};

    collumn.params.forEach((i) => inputData[i.name] =
        PropertyInfo(type: matchType(i.type), enumValues: i.listOption));

    final client = ApiClient(basePath: "https://demo.coflnet.com");
    final result = await TabApi(client).post(
        tabRequest: TabRequest(
            requiredColums: [],
            text: inputText,
            columnWithDescription: inputData));
    if (result == null) {
      throw Exception("result in recent log request is null");
    }
    print("InputData: $inputText \n Request Result: $result");
    List<col> newCollumns = [];
    for (var object in result) {
      col newCollumn = collumn.copy();
      object.forEach((String colKey, k) {
        newCollumn.params.forEach((key) {
          if (key.name == colKey) {
            print("setting value to $k");
            key["value"] = k;
          }
        });
      });
      newCollumns.add(newCollumn);
    }
    print("new collumn values ${newCollumns[0].toString()}");
    RecentLogHandler().addRecentLog(newCollumns);

    return newCollumns;
  }
}

FunctionObjectTypes matchType(String type) {
  switch (type) {
    case "String":
      return FunctionObjectTypes.string;
    case "List":
      return FunctionObjectTypes.string;
    case "0/10":
      return FunctionObjectTypes.integer;
    default:
      print("default");
      return FunctionObjectTypes.string;
  }
}
