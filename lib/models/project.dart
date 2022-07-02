import 'package:web3dart/web3dart.dart';

import 'chain_enum.dart';
import 'launchpad_enum.dart';

class Project {
  int? id;
  final int launchpadId;
  final ChainEnum chain;
  final String idInLaunchpad;
  String title;
  String symbol;
  DateTime? dateTimeInserted;
  DateTime? dateTimeUpdated;
  EthereumAddress? tokenAddress;
  DateTime? dateTimePoolCreationEstimate;
  int? firstLiquidityBlock;
  ProjectStatus status;
  int? lockPid;
  double? presaleUsdPrice;
  double? initialDexUsdPrice;
  double? xAfterStopLoss;
  bool tradable;

  Project({
    required this.id,
    required this.launchpadId,
    required this.chain,
    required this.idInLaunchpad,
    required this.title,
    required this.symbol,
    required this.dateTimeInserted,
    required this.dateTimeUpdated,
    required this.tokenAddress,
    required this.dateTimePoolCreationEstimate,
    required this.firstLiquidityBlock,
    required this.status,
    required this.lockPid,
    required this.presaleUsdPrice,
    required this.initialDexUsdPrice,
    required this.xAfterStopLoss,
    required this.tradable,
  });

  String get launchpadTitle {
    switch (launchpadId) {
      case LaunchpadIds.auto:   return LaunchpadTitles.auto;
      case LaunchpadIds.manual: return LaunchpadTitles.manual;
      case LaunchpadIds.bscpad: return LaunchpadTitles.bscpad;
      case LaunchpadIds.gamefi: return LaunchpadTitles.gamefi;
    }
    return launchpadId.toString();
  }
}

enum ProjectStatus {
  /// Just saved, to be determined.
  unknown,

  /// Not processed in any way.
  ignored,

  /// No token address, no dates.
  addressUnknown,

  /// Address is known, no pools, no dates. Not trying to trade.
  address,

  /// Monitoring liquidity, will buy if appears.
  tradingLazy,

  /// Sending transactions trying to buy.
  tradingAttempt,

  /// Pools exist in balance, no trading is viable anymore.
  past,

  /// A past pool with historical reserves exported to the database.
  dumped,

  /// A dumped pool with metrics computed from historical data.
  analyzed,
}
