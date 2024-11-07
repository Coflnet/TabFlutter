import 'package:csv/csv.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

class ConvertCsv {
  String convertCsv(List<col> cols) {
    List<String> headers = cols[0].params.map((c) => c.name).toList();
    if (headers.contains(translate("weather"))) {
      headers.removeWhere((i) => i == translate("weather"));
      headers.addAll([
        translate("weather"),
        translate("humidity"),
        translate("temperature")
      ]);
    }
    List<List<String>> csvData = [headers];

    for (var c in cols) {
      List<String> addLast = [];
      List<String> row = [];
      for (var p in c.params) {
        if (p.type == translate("weather")) {
          addLast
              .addAll(["${p.svalue[0]}", "${p.svalue[1]}", "${p.svalue[2]}"]);
          continue;
        }
        row.add(p.svalue ?? '');
      }
      if (addLast.isNotEmpty) {
        row.addAll(addLast);
      }
      csvData.add(row);
    }

    return const ListToCsvConverter().convert(csvData);
  }
}
