import 'package:csv/csv.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

class ConvertCsv {
  String convertCsv(List<col> cols) {
    List<String> headers = [
      'table_name',
      'column_name',
      'column_svalue',
    ];
    List<List<String>> csvData = [headers];

    for (var c in cols) {
      for (var p in c.params) {
        csvData.add([
          c.name,
          p.name,
          p.svalue ?? '',
        ]);
      }
    }

    return const ListToCsvConverter().convert(csvData);
  }
}
