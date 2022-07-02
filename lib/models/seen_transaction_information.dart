import 'package:web3dart/web3dart.dart';

class SeenTransactionInformation {
  final DateTime dateTimeSeen;
  final TransactionInformation transactionInformation;

  SeenTransactionInformation({
    required this.dateTimeSeen,
    required this.transactionInformation,
  });
}
