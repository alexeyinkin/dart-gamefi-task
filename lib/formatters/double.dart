import 'package:intl/intl.dart';

class WholeDoubleFormatter {
  final _numberFormat = NumberFormat('###,###,###,###,###,###,###,###,###,###,###,###,##0');

  String format(double amount, {String? symbol}) {
    final formatted = _numberFormat.format(amount);

    if (symbol == null) return '$formatted';
    return '$formatted $symbol';
  }
}

class CentDoubleFormatter {
  final _numberFormat = NumberFormat('###,###,###,###,###,###,###,###,###,###,###,###,##0.00');

  String format(double amount, {String? symbol}) {
    final formatted = _numberFormat.format(amount);

    if (symbol == null) return '$formatted';
    return '$formatted $symbol';
  }
}
