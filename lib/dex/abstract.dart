import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:web3dart/web3dart.dart';

import '../chain_clients/abstract.dart';
import '../contracts/erc20.dart';
import '../contracts/pair.dart';
import '../models/chain_enum.dart';
import '../models/dex_enum.dart';
import '../services/usd_native_converter.dart';
import '../utils/utils.dart';

abstract class AbstractDex {
  final _logger = Logger('AbstractDex');
  final AbstractChainClient client;
  final _pairInfoCache = <String, DexPairInfo>{};
  final _pairInfoCacheByAddress = <EthereumAddress, DexPairInfo>{};
  final _lpInfoCache = <EthereumAddress, Map<int, LiquidityPoolInfo>>{};
  final _usdPriceCache = <EthereumAddress, Map<int, double?>>{};
  UsdNativeConverter? _usdNativeConverter;
  int get id;
  DexEnum get dexEnum;
  ChainEnum get chainEnum;
  String get name;
  int get ttlSeconds;

  AbstractDex({
    required this.client,
  });

  /// Returns addresses against which tokens commonly trade.
  List<EthereumAddress> getOtherAddresses();

  Future<DexPairInfo> getPairInfoByAddress(EthereumAddress address) async {
    if (!_pairInfoCacheByAddress.containsKey(address)) {
      _cachePairInfo(await requestPairInfoByAddress(address));
    }
    return _pairInfoCacheByAddress[address]!;
  }

  Future<DexPairInfo> getStablePairInfo(EthereumAddress other) async {
    return getPairInfo(other, client.usdStableCoinAddress!);
  }

  Future<DexPairInfo> getPairInfo(EthereumAddress addressA, EthereumAddress addressB) async {
    final key = '$addressA-$addressB';
    if (!_pairInfoCache.containsKey(key)) {
      final result = await requestPairInfo(addressA, addressB);
      _cachePairInfo(result);
      return result;
    }
    return _pairInfoCache[key]!;
  }

  void _cachePairInfo(DexPairInfo pi) {
    // Only cache deployed pairs.
    if (pi.lpAddress == null) return;

    final address0 = pi.contract?.contract0.address;
    final address1 = pi.contract?.contract1.address;

    final key01 = '$address0-$address1';
    if (!_pairInfoCache.containsKey(key01)) _pairInfoCache[key01] = pi;

    final key10 = '$address1-$address0';
    if (!_pairInfoCache.containsKey(key10)) _pairInfoCache[key10] = pi;

    if (!_pairInfoCacheByAddress.containsKey(pi.lpAddress)) {
      _pairInfoCacheByAddress[pi.lpAddress!] = pi;
    }
  }

  /// [forceLive] forces non-archive server, this may still be cached in this object.
  Future<LiquidityPoolInfo> getLiquidityPoolInfo(DexPairInfo pairInfo, {
    BlockNum? atBlock,
    bool forceLive = false,
  }) async {
    if (atBlock == null) return requestLiquidityPoolInfo(pairInfo);

    final address = pairInfo.lpAddress!;

    if (!_lpInfoCache.containsKey(address)) {
      _lpInfoCache[address] = <int, LiquidityPoolInfo>{};
    }

    if (!_lpInfoCache[address]!.containsKey(atBlock.blockNum)) {
      _lpInfoCache[address]![atBlock.blockNum] = await requestLiquidityPoolInfo(
        pairInfo,
        atBlock: atBlock,
        forceLive: forceLive,
      );
    }

    return _lpInfoCache[address]![atBlock.blockNum]!;
  }

  // TODO: Allow to be live, change all other USD-Native conversions to use this.
  Future<UsdNativeConverter> getUsdNativeConverter() async {
    if (_usdNativeConverter == null) {
      _usdNativeConverter = UsdNativeConverter();
      await updateUsdNativeConverter();
    }
    return _usdNativeConverter!;
  }

  @protected
  Future<void> updateUsdNativeConverter();

  Future<DexPairInfo> requestPairInfo(EthereumAddress addressA, EthereumAddress addressB);
  Future<DexPairInfo> requestPairInfoByAddress(EthereumAddress address);
  Future<LiquidityPoolInfo> requestLiquidityPoolInfo(DexPairInfo pairInfo, {BlockNum? atBlock, bool forceLive = false});
  Future<double?> requestTokenUsdPrice(EthereumAddress address, {BlockNum? atBlock});

  SwapLog? parseSwapLog(FilterEvent log) => null;

  /// Addresses that must be approved to spend ERC-20 tokens before trading.
  List<EthereumAddress> getSpenderAddresses() => [];

  Future<List<SentTransaction>> approveIfNot({
    required EthereumAddress token,
  }) async {
    final result = <SentTransaction>[];

    for (final spender in getSpenderAddresses()) {
      result.addAll(
        await client.approveIfNot(token: token, spender: spender),
      );
    }

    return result;
  }
}

class DexPairInfo<C extends AbstractPairDeployedContract> {
  final EthereumAddress? lpAddress;
  final C? contract;
  final EthereumAddress addressA;
  final EthereumAddress addressB;

  bool get isDeployed => contract?.address.isNotNull ?? false;

  DexPairInfo({
    required this.lpAddress,
    required this.contract,
    required this.addressA,
    required this.addressB,
  });

  const DexPairInfo.notExistent({
    required this.addressA,
    required this.addressB,
  }) :
        lpAddress = null,
        contract = null;

  Erc20DeployedContract? getOneContract(EthereumAddress address) {
    if (contract == null) return null;
    if (contract!.contract0.address == address) return contract!.contract0;
    if (contract!.contract1.address == address) return contract!.contract1;
    throw Exception('Address not in pair: $address, pair $lpAddress');
  }

  Erc20DeployedContract? getOtherContract(EthereumAddress address) {
    if (contract == null) return null;
    if (contract!.contract0.address == address) return contract!.contract1;
    if (contract!.contract1.address == address) return contract!.contract0;
    throw Exception('Address not in pair: $address, pair $lpAddress');
  }
}

class LiquidityPoolInfo {
  final Reserves reserves;

  const LiquidityPoolInfo({
    required this.reserves,
  });

  const LiquidityPoolInfo.empty() :
        reserves = const Reserves.empty();
}

class Swap {
  final List<EthereumAddress> path;
  final BigInt amountInMax;
  final BigInt amountIn;
  final BigInt amountOutMin;
  final BigInt amountOut;
  final String function;
  final int deadline;
  final double highestPrice;
  final bool status;

  Swap({
    required this.path,
    required this.amountInMax,
    required this.amountIn,
    required this.amountOutMin,
    required this.amountOut,
    required this.function,
    required this.deadline,
    required this.highestPrice,
    required this.status,
  });
}

class DirectedSwap {
  final Swap swap;
  final TokenSwapDirection direction;

  BigInt get tokenAmount => direction == TokenSwapDirection.sell ? swap.amountIn : swap.amountOut;
  BigInt get otherAmount => direction == TokenSwapDirection.sell ? swap.amountOut : swap.amountIn;
  EthereumAddress get tokenAddress => direction == TokenSwapDirection.sell ? swap.path.first : swap.path.last;
  EthereumAddress get otherAddress => direction == TokenSwapDirection.sell ? swap.path.last : swap.path.first;

  DirectedSwap._({
    required this.swap,
    required this.direction,
  });

  static DirectedSwap? fromSwapAndToken(Swap swap, EthereumAddress tokenAddress) {
    if (swap.path.last == tokenAddress) {
      return DirectedSwap._(
        swap: swap,
        direction: TokenSwapDirection.buy,
      );
    }

    if (swap.path.first == tokenAddress) {
      return DirectedSwap._(
        swap: swap,
        direction: TokenSwapDirection.sell,
      );
    }

    if (swap.path.contains(tokenAddress)) {
      throw Exception('Transitional swaps with the given token in between are not supported.');
    }

    return null;
  }
}

enum TokenSwapDirection {
  buy,
  sell,
}

class LiquidityRequest {
  final LiquidityAction action;
  final EthereumAddress addressA;
  final EthereumAddress addressB;
  final BigInt amountAMin;
  final BigInt amountBMin;
  final String function;

  LiquidityRequest({
    required this.action,
    required this.addressA,
    required this.addressB,
    required this.amountAMin,
    required this.amountBMin,
    required this.function,
  });

  EthereumAddress getOtherAddress(EthereumAddress address) {
    if (address == addressA) return addressB;
    if (address == addressB) return addressA;
    throw Exception('$address is neither $addressA nor $addressB');
  }

  bool hasAddress(EthereumAddress address) {
    return addressA == address || addressB == address;
  }

  BigInt getAmountMinByAddress(EthereumAddress address) {
    if (address == addressA) return amountAMin;
    if (address == addressB) return amountBMin;
    throw Exception('$address is neither $addressA nor $addressB');
  }
}

class LiquidityEvent {
  final LiquidityRequest request;
  final BigInt amountA;
  final BigInt amountB;

  BigInt getAmountByAddress(EthereumAddress address) {
    if (address == request.addressA) return amountA;
    if (address == request.addressB) return amountB;
    throw Exception('$address is neither ${request.addressA} nor ${request.addressB}');
  }

  LiquidityEvent({
    required this.request,
    required this.amountA,
    required this.amountB,
  });
}

enum LiquidityAction {
  add,
  remove,
}

class SwapLog {
  final BigInt amount0In;
  final BigInt amount1In;
  final BigInt amount0Out;
  final BigInt amount1Out;

  BigInt get netAmount0In => amount0In - amount0Out;
  BigInt get netAmount1In => amount1In - amount1Out;
  BigInt get netAmount0Out => amount0Out - amount0In;
  BigInt get netAmount1Out => amount1Out - amount1In;

  BigInt getNetAmountIn(int index) {
    switch (index) {
      case 0: return netAmount0In;
      case 1: return netAmount1In;
    }
    throw RangeError.range(index, 0, 1);
  }

  BigInt getNetAmountOut(int index) {
    switch (index) {
      case 0: return netAmount0Out;
      case 1: return netAmount1Out;
    }
    throw RangeError.range(index, 0, 1);
  }

  SwapLog({
    required this.amount0In,
    required this.amount1In,
    required this.amount0Out,
    required this.amount1Out,
  });
}
