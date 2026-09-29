import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_entry/globals/app_messenger.dart';
import 'package:table_entry/globals/columns/editColumnsClasses.dart';
import 'package:table_entry/globals/convert_tsv.dart';

/// Copies [entries] as TSV (header + rows) so they can be pasted into Excel
/// or LibreOffice, and confirms with a SnackBar.
Future<void> copyEntriesToClipboard(List<col> entries) async {
  if (entries.isEmpty) {
    showAppSnackBar(translate('noEntries'));
    return;
  }
  try {
    await Clipboard.setData(
        ClipboardData(text: ConvertTsv().convertTsv(entries)));
    showAppSnackBar(
        translate('entriesCopied', args: {'count': entries.length}));
  } catch (e) {
    showAppSnackBar(translate('copyFailed'), error: true);
  }
}
