import 'dart:ui' as ui;

import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/convert_tsv.dart';

/// CSV that Excel opens correctly on double-click: UTF-8 with BOM (so
/// umlauts survive) and the list separator Excel expects for the locale.
class ConvertCsv {
  static const String bom = '﻿';

  /// Languages whose number format uses a decimal comma; Excel then expects
  /// `;` as the CSV separator.
  static const Set<String> _decimalCommaLanguages = {
    'af',
    'az',
    'be',
    'bg',
    'bs',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'es',
    'et',
    'eu',
    'fi',
    'fo',
    'fr',
    'gl',
    'hr',
    'hu',
    'hy',
    'id',
    'is',
    'it',
    'ka',
    'kk',
    'lb',
    'lt',
    'lv',
    'mk',
    'mn',
    'nb',
    'nl',
    'nn',
    'no',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sq',
    'sr',
    'sv',
    'tr',
    'uk',
    'uz',
    'vi',
  };

  /// Spanish-speaking regions that use a decimal point.
  static const Set<String> _decimalPointRegions = {
    'MX',
    'US',
    '419',
    'PR',
    'DO',
    'GT',
    'HN',
    'NI',
    'PA',
    'SV',
  };

  /// `;` for locales with a decimal comma (de, fr, es, it, nl, …), else `,`.
  static String separatorFor(ui.Locale locale) {
    final language = locale.languageCode.toLowerCase();
    if (!_decimalCommaLanguages.contains(language)) return ',';
    if (language == 'es' &&
        _decimalPointRegions.contains(locale.countryCode?.toUpperCase())) {
      return ',';
    }
    return ';';
  }

  /// Separator for the device locale.
  static String deviceSeparator() =>
      separatorFor(ui.PlatformDispatcher.instance.locale);

  /// Quotes a field that contains the separator, `"`, CR or LF.
  static String encodeField(String value, String separator) {
    if (value.contains(separator) || value.contains(RegExp('["\r\n]'))) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Fields joined by [separator], rows by `\r\n`.
  static String encodeRows(List<List<String>> rows, String separator) => rows
      .map((r) => r.map((f) => encodeField(f, separator)).join(separator))
      .join('\r\n');

  /// The entries of one table as CSV, prefixed with a BOM.
  String convertCsv(List<col> cols,
      {String? separator, bool withBom = true, WeatherLabels? labels}) {
    final sep = separator ?? deviceSeparator();
    final csv = encodeRows(tableRows(cols, labels: labels), sep);
    return withBom ? '$bom$csv' : csv;
  }
}
