import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/convertCSV.dart';
import 'package:table_entry/globals/convert_tsv.dart';

const labels = WeatherLabels(
    weather: 'Wetter', humidity: 'Luftfeuchtigkeit', temperature: 'Temperatur');

col entry(Map<String, dynamic> values, {String table = 'Bestellungen'}) =>
    col(name: table, emoji: '', id: 1, params: [
      for (final e in values.entries)
        param(
            name: e.key,
            type: e.key == 'Wetter' ? 'Wetter' : 'String',
            svalue: e.value)
    ]);

/// Representative sample: umlauts, a newline, a quote, a decimal comma and
/// a date.
List<col> sample() => [
      entry({
        'Artikel': 'Flansch DN50',
        'Menge': '20',
        'Preis': '12,50',
        'Kunde': 'Müller GmbH',
        'Notiz': 'Er sagte "sofort"',
        'Lieferdatum': '2026-10-01',
      }),
      entry({
        'Artikel': 'Dichtung ÄÖÜ äöü ß',
        'Menge': '3',
        'Preis': '0,99',
        'Kunde': 'Schröder & Söhne',
        'Notiz': 'Zeile 1\nZeile 2',
        'Lieferdatum': '2026-12-24',
      }),
    ];

void main() {
  group('TSV', () {
    test('header row, tab between fields, CRLF between rows', () {
      final tsv = ConvertTsv().convertTsv([
        entry({'A': '1', 'B': '2'}),
        entry({'A': '3', 'B': '4'}),
      ], labels: labels);
      expect(tsv, 'A\tB\r\n1\t2\r\n3\t4');
    });

    test('quotes fields with tab, CR, LF or quote and doubles inner quotes',
        () {
      expect(ConvertTsv.encodeField('a\tb'), '"a\tb"');
      expect(ConvertTsv.encodeField('a\nb'), '"a\nb"');
      expect(ConvertTsv.encodeField('a\rb'), '"a\rb"');
      expect(
          ConvertTsv.encodeField('Er sagte "sofort"'), '"Er sagte ""sofort"""');
      expect(ConvertTsv.encodeField('12,50'), '12,50');
      expect(ConvertTsv.encodeField('a;b'), 'a;b');
    });

    test('keeps umlauts as they are', () {
      final tsv = ConvertTsv().convertTsv(sample(), labels: labels);
      expect(tsv, contains('Müller GmbH'));
      expect(tsv, contains('Dichtung ÄÖÜ äöü ß'));
      expect(tsv.startsWith('﻿'), isFalse);
    });

    test('expands the weather column at the end like the CSV export', () {
      final rows = tableRows([
        entry({
          'Wetter': ['Sonnig', '40%', '21°C'],
          'Artikel': 'Flansch'
        }),
      ], labels: labels);
      expect(rows, [
        ['Artikel', 'Wetter', 'Luftfeuchtigkeit', 'Temperatur'],
        ['Flansch', 'Sonnig', '40%', '21°C'],
      ]);
    });

    test('weather without values gives empty cells, not a crash', () {
      final rows = tableRows([
        entry({'Wetter': '', 'Artikel': 'Flansch'}),
      ], labels: labels);
      expect(rows[1], ['Flansch', '', '', '']);
    });

    test('entries of different tables become separate blocks', () {
      final tsv = ConvertTsv().convertTsv([
        entry({'A': '1'}, table: 'T1'),
        entry({'X': 'x'}, table: 'T2'),
        entry({'A': '2'}, table: 'T1'),
      ], labels: labels);
      expect(tsv, 'A\r\n1\r\n2\r\n\r\nX\r\nx');
    });
  });

  group('CSV', () {
    test('starts with a UTF-8 BOM', () {
      final csv =
          ConvertCsv().convertCsv(sample(), separator: ';', labels: labels);
      expect(csv.startsWith('﻿'), isTrue);
      expect(utf8.encode(csv).take(3), [0xEF, 0xBB, 0xBF]);
    });

    test('semicolon separator keeps decimal commas unquoted', () {
      final csv = ConvertCsv()
          .convertCsv(sample(), separator: ';', withBom: false, labels: labels);
      final lines = csv.split('\r\n');
      expect(lines.first, 'Artikel;Menge;Preis;Kunde;Notiz;Lieferdatum');
      expect(lines[1],
          'Flansch DN50;20;12,50;Müller GmbH;"Er sagte ""sofort""";2026-10-01');
      expect(csv, contains('"Zeile 1\nZeile 2"'));
    });

    test('comma separator quotes fields with commas', () {
      final csv = ConvertCsv()
          .convertCsv(sample(), separator: ',', withBom: false, labels: labels);
      expect(csv.split('\r\n')[1],
          'Flansch DN50,20,"12,50",Müller GmbH,"Er sagte ""sofort""",2026-10-01');
    });

    test('separator follows the decimal symbol of the locale', () {
      expect(ConvertCsv.separatorFor(const Locale('de', 'DE')), ';');
      expect(ConvertCsv.separatorFor(const Locale('de', 'CH')), ';');
      expect(ConvertCsv.separatorFor(const Locale('fr')), ';');
      expect(ConvertCsv.separatorFor(const Locale('es', 'ES')), ';');
      expect(ConvertCsv.separatorFor(const Locale('it')), ';');
      expect(ConvertCsv.separatorFor(const Locale('nl')), ';');
      expect(ConvertCsv.separatorFor(const Locale('en', 'US')), ',');
      expect(ConvertCsv.separatorFor(const Locale('en', 'GB')), ',');
      expect(ConvertCsv.separatorFor(const Locale('es', 'MX')), ',');
      expect(ConvertCsv.separatorFor(const Locale('ja')), ',');
    });

    test('empty input gives an empty file with BOM', () {
      expect(ConvertCsv().convertCsv([], separator: ';', labels: labels), '﻿');
    });
  });

  test('writes sample exports for the LibreOffice check', () {
    const dir = '/tmp/claude-1000/-home-ekwav-dev-TabApi/'
        '464bdb97-09b8-4fa0-a5d6-0948c405920a/scratchpad/export_samples';
    if (!Directory('/tmp/claude-1000').existsSync()) return;
    Directory(dir).createSync(recursive: true);
    File('$dir/sample.tsv').writeAsBytesSync(
        utf8.encode(ConvertTsv().convertTsv(sample(), labels: labels)));
    File('$dir/sample.csv').writeAsBytesSync(utf8.encode(
        ConvertCsv().convertCsv(sample(), separator: ';', labels: labels)));
    File('$dir/sample_comma.csv').writeAsBytesSync(utf8.encode(
        ConvertCsv().convertCsv(sample(), separator: ',', labels: labels)));
  });
}
