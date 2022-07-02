import 'dart:typed_data';

import 'package:web3dart/web3dart.dart';

import 'chain_enum.dart';

class Transaction {
  int? id;
  final ChainEnum chain;
  final String hash;
  final int block;
  final DateTime dateTime;
  final int index;
  final bool status;
  final int gasPriceWei;
  final EthereumAddress from;
  final EthereumAddress to;
  final String? function;
  final Uint8List input;
  final int nonce;
  final double valueDouble;

  Transaction({
    required this.id,
    required this.chain,
    required this.hash,
    required this.block,
    required this.dateTime,
    required this.index,
    required this.status,
    required this.gasPriceWei,
    required this.from,
    required this.to,
    required this.function,
    required this.input,
    required this.nonce,
    required this.valueDouble,
  });
}
