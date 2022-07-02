import 'package:web3dart/web3dart.dart';

import '../models/chain_enum.dart';
import '../models/project.dart';

abstract class AbstractLaunchpad {
  int get id;
  String get title;
  Future<List<GrabbedProject>> getProjects();
}

class GrabbedProject {
  final int launchpadId;
  final ChainEnum chain;
  final String idInLaunchpad;
  final String title;
  final String symbol;
  final EthereumAddress? tokenAddress;
  final EthereumAddress? otherAddress;
  final DateTime? dateTimePoolCreationEstimate;
  final int? firstLiquidityBlock;
  final double? initialDexUsdPrice;
  final double? initialTokenReserve;
  final ProjectStatus? status;

  GrabbedProject({
    required this.launchpadId,
    required this.chain,
    required this.idInLaunchpad,
    required this.title,
    required this.symbol,
    required this.tokenAddress,
    this.otherAddress,
    required this.dateTimePoolCreationEstimate,
    this.firstLiquidityBlock,
    this.initialDexUsdPrice,
    this.initialTokenReserve,
    this.status,
  });

  double? get initialHalfPoolUsdValue {
    return initialTokenReserve == null || initialDexUsdPrice == null
        ? null
        : initialTokenReserve! * initialDexUsdPrice!;
  }
}
