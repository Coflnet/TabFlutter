import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';

/// Labels of the three columns a weather column is expanded into.
class WeatherLabels {
  final String weather;
  final String humidity;
  final String temperature;

  const WeatherLabels(
      {required this.weather,
      required this.humidity,
      required this.temperature});

  factory WeatherLabels.translated() => WeatherLabels(
      weather: translate("weather"),
      humidity: translate("humidity"),
      temperature: translate("temperature"));
}

/// Header row plus one row per entry of a single table. A weather column is
/// moved to the end and expanded into weather, humidity and temperature, the
/// same way the CSV export always did.
List<List<String>> tableRows(List<col> cols, {WeatherLabels? labels}) {
  if (cols.isEmpty) return [];
  final l = labels ?? WeatherLabels.translated();
  bool isWeather(param p) => p.type == l.weather;

  final headers = <String>[];
  var hasWeather = false;
  for (final p in cols[0].params) {
    if (isWeather(p)) {
      hasWeather = true;
      continue;
    }
    headers.add(p.name);
  }
  if (hasWeather) headers.addAll([l.weather, l.humidity, l.temperature]);

  final rows = <List<String>>[headers];
  for (final c in cols) {
    final row = <String>[];
    final addLast = <String>[];
    for (final p in c.params) {
      if (isWeather(p)) {
        final v = p.svalue;
        String at(int i) => v is List && v.length > i ? '${v[i] ?? ''}' : '';
        addLast.addAll([at(0), at(1), at(2)]);
        continue;
      }
      row.add(cellText(p.svalue));
    }
    row.addAll(addLast);
    rows.add(row);
  }
  return rows;
}

/// Text of one cell; lists (multi-value columns) are joined with ", ".
String cellText(dynamic value) {
  if (value == null) return '';
  if (value is List) return value.map(cellText).join(', ');
  return value.toString();
}

/// Splits [cols] by table (entry name), keeping the order of first
/// appearance, because every table has its own columns.
List<List<col>> groupByTable(List<col> cols) {
  final groups = <String, List<col>>{};
  for (final c in cols) {
    groups.putIfAbsent(c.name, () => []).add(c);
  }
  return groups.values.toList();
}

/// Tab separated text that Excel and LibreOffice split into cells on paste.
class ConvertTsv {
  /// Quotes a field that contains a tab, CR, LF or `"`; inner quotes are
  /// doubled.
  static String encodeField(String value) {
    if (value.contains(RegExp('[\t\r\n"]'))) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Fields joined by `\t`, rows by `\r\n`.
  static String encodeRows(List<List<String>> rows) =>
      rows.map((r) => r.map(encodeField).join('\t')).join('\r\n');

  /// All entries as TSV. Entries of different tables become separate blocks
  /// (each with its own header row) divided by an empty line.
  String convertTsv(List<col> cols, {WeatherLabels? labels}) =>
      groupByTable(cols)
          .map((group) => encodeRows(tableRows(group, labels: labels)))
          .join('\r\n\r\n');
}
