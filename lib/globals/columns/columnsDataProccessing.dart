import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/recentLogRequest/recentLogHandler.dart';

String fileName = "";
String selectedColumn = "";
DateTime afterDate = DateTime.utc(1989, 11, 9);

class ColumnsDataProccessing {
  List<col> getColumnData() {
    List<col> columnData = [];
    columnData = getAllColumnsWithName();
    columnData = getColumnsAfterTime(columnData);
    return columnData;
  }

  List<col> getColumnsAfterTime(List<col> unProccessedCol) {
    List<col> proccessedCol = [];
    for (var i in unProccessedCol) {
      if (i.createdDate.isAfter(afterDate)) {
        proccessedCol.add(i);
      }
    }
    return proccessedCol;
  }

  List<col> getAllColumnsWithName() {
    final allColumns = RecentLogHandler().getRecentLog;
    List<col> namedCollumns = [];
    for (var i in allColumns) {
      if (i.name == selectedColumn) {
        namedCollumns.add(i);
      }
    }
    return namedCollumns;
  }

  String get getFileName => fileName;
  String get getSelectedColumn => selectedColumn;
  set setFileName(v) => fileName = v;
  set setSelectedColumn(v) => selectedColumn = v;
  set setAfterDate(v) => afterDate = v;
}
