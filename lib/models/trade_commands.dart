import 'package:web3dart/web3dart.dart';

import 'in_out.dart';

abstract class TradeCommand {}

class BuyIntCommand extends TradeCommand {
  final List<EthereumAddress> path;
  final InOut inOut;
  final EtherAmount? gasPrice;
  final String? backrunTargetHash;

  BuyIntCommand({
    required this.path,
    required this.inOut,
    this.gasPrice,
    this.backrunTargetHash,
  });
}
