import 'package:web3dart/web3dart.dart';

class AmountFormatter {
  final int fractionDigits;

  AmountFormatter({
    required this.fractionDigits,
  });

  String format(EtherAmount amount, String symbol) {
    final v = amount.getValueInUnit(EtherUnit.ether).toStringAsFixed(fractionDigits);
    return '$v $symbol';
  }
}
