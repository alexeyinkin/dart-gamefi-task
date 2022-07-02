import 'package:web3dart/web3dart.dart';

import 'amount.dart';
import 'chain.dart';
import 'database.dart';
import 'dump.dart';
import 'telegram.dart';
import '../models/chain_enum.dart';
import '../models/dex_enum.dart';
import '../utils/utils.dart';

class Config {
  final ChainEnum chain;
  final DexEnum dex;
  final EthereumAddress tokenAddress;
  final String? otherAddressString;
  final Map<ChainEnum, ChainConfig> chains;
  final int attemptsPerMinute;
  final AmountConfig amount;
  final DumpConfig? dump;
  final DatabaseConfig? database;
  final TelegramConfig? telegram;

  // TODO: Get actual from client and dex.
  static const _nativeDecimals = 18;
  static const _usdDecimals = 18;

  Config({
    required this.chain,
    required this.dex,
    required this.tokenAddress,
    required this.otherAddressString,
    required this.chains,
    required this.attemptsPerMinute,
    required this.amount,
    required this.dump,
    required this.database,
    required this.telegram,
  });

  factory Config.fromMap(Map map) {
    return Config(
      chain:                  ChainEnum.values.byName(map['chain']),
      dex:                    DexEnum.values.byName(map['dex']),
      tokenAddress:           EthereumAddress.fromHex(map['tokenAddress']),
      otherAddressString:     map['otherAddress'],
      chains:                 ChainConfig.fromMaps(map['chains'] ?? {}),
      attemptsPerMinute:      toIntIfNot(map['attemptsPerMinute']),
      amount:                 AmountConfig.fromMap(map['amount'], nativeDecimals: _nativeDecimals, usdDecimals: _usdDecimals),
      dump:                   DumpConfig.fromMapOrNull(map['dump']),
      database:               DatabaseConfig.fromMap(map['database']),
      telegram:               TelegramConfig.fromMap(map['telegram']),
    );
  }
}
