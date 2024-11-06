import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/generatedCode/api.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';
import 'package:table_entry/globals/weatherService.dart';

List weatherCache = [];

class RecentLogRequest {
  Future<List<col>> request(String inputText, col collumn) async {
    Map<String, PropertyInfo> inputData = {};

    for (var i in collumn.params) {
      if (checkType(i)) continue;
      inputData[i.name] =
          PropertyInfo(type: matchType(i.type), enumValues: i.listOption);
    }

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
        for (var key in newCollumn.params) {
          if (key.name == colKey) {
            print("setting value to $k");
            key["value"] = k;
          }
        }
      });
      newCollumn.createdDate = DateTime.now();
      newCollumn.id =
          RecentLogHandler().getRecentLog.length + 1 + newCollumns.length;
      newCollumns.add(newCollumn);
    }
    print("new collumn values ${newCollumns[0].toString()}");
    RecentLogHandler().addRecentLog(newCollumns);

    return newCollumns;
  }
}

bool checkType(param i) {
  if (i.type == translate("date")) {
    i.svalue = DateTime.now().toIso8601String();
    return true;
  }
  if (i.type == translate("weather")) {
    if (weatherCache.isEmpty) {
      getWeatherData(i);
      return true;
    }
    i.svalue = weatherCache;
    return true;
  }
  return false;
}

void getWeatherData(param i) async {
  final List<dynamic> weatherResult = await WeatherService().getCityName();
  if (weatherResult.isEmpty) {
    i.svalue = ["ERROR", "PERMS DENIED", "CONTACT SUPPORT!"];
    return;
  }
  i.svalue = weatherResult;
  weatherCache = weatherResult;
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
