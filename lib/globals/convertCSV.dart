import 'package:csv/csv.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

class ConvertCsv {
  String convertCsv(List<col> cols) {
    List<String> headers = cols[0].params.map((c) => c.name).toList();
    List<List<String>> csvData = [headers];

    for (var c in cols) {
      List<String> row = [];
      for (var p in c.params) {
        row.add(p.svalue ?? '');
      }
      csvData.add(row);
    }

    return const ListToCsvConverter().convert(csvData);
  }
}
