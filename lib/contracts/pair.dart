import 'package:web3dart/web3dart.dart';

import '../chain_clients/abstract.dart';
import '../contracts/erc20.dart';

abstract class AbstractPairDeployedContract extends DeployedContract {
  final Erc20DeployedContract contract0;
  final Erc20DeployedContract contract1;

  AbstractPairDeployedContract({
    required ContractAbi abi,
    required EthereumAddress address,
    required this.contract0,
    required this.contract1,
  }) : super(
    abi,
    address,
  );

  bool hasAddress(EthereumAddress address) {
    return contract0.address == address || contract1.address == address;
  }

  int requireAddressIndex(EthereumAddress address) {
    if (contract0.address == address) return 0;
    if (contract1.address == address) return 1;
    throw Exception('Address $address not found in the pair.');
  }

  Future<Reserves> getReserves(AbstractChainClient client, {BlockNum? atBlock, bool forceLive = false});
  LiquidityEmittedEvent? parseMintEvent(FilterEvent log);
  LiquidityEmittedEvent? parseBurnEvent(FilterEvent log);

  Future<int?> getFirstLiquidityBlock(AbstractChainClient client) async {
    final lastBlock = await client.client.getBlockNumber();
    final lastReserves = await getReserves(client, atBlock: BlockNum.exact(lastBlock), forceLive: true);
    if (lastReserves.isEmpty) return null;

    int lower = 0;
    int upper = lastBlock;

    while (true) {
      int n = (lower + upper) ~/ 2;
      if (n == lower) return upper;

      final reserves = await getReserves(client, atBlock: BlockNum.exact(n));

      if (reserves.isEmpty) {
        lower = n;
      } else {
        upper = n;
      }
    }
  }
}

class Reserves {
  final Map<EthereumAddress, BigInt> bigIntByToken;
  final Map<EthereumAddress, double> doubleByToken;

  bool get isEmpty => bigIntByToken.values.where((v) => v != BigInt.zero).isEmpty;

  const Reserves({
    required this.bigIntByToken,
    required this.doubleByToken,
  });

  const Reserves.empty() :
      bigIntByToken = const {},
      doubleByToken = const {};

  BigInt getBigIntByToken(EthereumAddress address) => bigIntByToken[address] ?? BigInt.zero;
  double getDoubleByToken(EthereumAddress address) => doubleByToken[address] ?? .0;

  double? getIntTokenPriceOrNull(EthereumAddress priceOf, EthereumAddress priceIn) {
    final amountIn = bigIntByToken[priceIn];
    final amountOf = bigIntByToken[priceOf];
    return amountIn == null || amountOf == null || (amountIn == BigInt.zero && amountOf == BigInt.zero)
        ? null
        : amountIn / amountOf;
  }

  double? getTokenPriceOrNull(EthereumAddress priceOf, EthereumAddress priceIn) {
    final amountIn = doubleByToken[priceIn];
    final amountOf = doubleByToken[priceOf];
    return amountIn == null || amountOf == null || (amountIn == 0 && amountOf == 0)
        ? null
        : amountIn / amountOf;
  }

  double getTokenPrice(EthereumAddress priceOf, EthereumAddress priceIn) {
    final result = getTokenPriceOrNull(priceOf, priceIn);
    if (result == null) throw Exception('No reserves to calculate price $priceOf in $priceIn');
    return result;
  }

  double getHalfPoolValue(Map<EthereumAddress, double> rates) {
    for (final entry in doubleByToken.entries) {
      if (rates.containsKey(entry.key)) {
        return entry.value * rates[entry.key]!;
      }
    }

    throw Exception('No rate to measure value.');
  }
}

class LiquidityEmittedEvent {
  final BigInt amount0;
  final BigInt amount1;

  LiquidityEmittedEvent({
    required this.amount0,
    required this.amount1,
  });

  BigInt getAmount(int index) {
    switch (index) {
      case 0: return amount0;
      case 1: return amount1;
    }
    throw RangeError.range(index, 0, 1);
  }
}
