import 'dart:math';

import '../utils/utils.dart';

class TableFormatter {
  final Map<String, ColumnFormatter> columns;
  final ColumnSeparator separator;

  TableFormatter({
    required this.columns,
    required this.separator,
  });

  String formatHeader() {
    return formatData(
      columns.map((name, column) => MapEntry(name, column.title)),
    );
  }

  String formatData(Map<String, dynamic> data) {
    final parts = <String>[];

    for (final entry in columns.entries) {
      final name = entry.key;
      final value = data[name];
      final str = value == null ? '' : value.toString();
      parts.add(_pad(name, str));
    }

    switch (separator) {
      case ColumnSeparator.spaces:
        return parts.join('  ');
      case ColumnSeparator.tab:
        return parts.join('\t');
    }

    throw Exception('Unknown separator: $separator');
  }

  String _pad(String name, String value) {
    switch (separator) {
      case ColumnSeparator.spaces:
        final column = columns[name]!;
        final length = column.length;
        if (length == null) return value;

        final pushedLength = max(length, column.title.length);
        final cropped = column.crop ? value.shortenIfLonger(pushedLength) : value;

        switch (column.alignment) {
          case ColumnAlignment.left:
            return cropped.padRight(pushedLength);
          case ColumnAlignment.right:
            return cropped.padLeft(pushedLength);
        }
        throw Exception('Unknown alignment: ${column.alignment}');

      default:
        return value;
    }
  }
}

enum ColumnSeparator {
  spaces,
  tab,
}

class ColumnFormatter {
  final String title;
  final int? length;
  final ColumnAlignment alignment;
  final bool crop;

  ColumnFormatter({
    required this.title,
    this.length,
    this.alignment = ColumnAlignment.left,
    this.crop = true,
  });
}

enum ColumnAlignment {
  left,
  right,
}
