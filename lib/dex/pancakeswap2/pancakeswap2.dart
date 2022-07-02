import 'package:swap_bot/chain_clients/bsc_client.dart';
import 'package:swap_bot/contracts/pair.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../abstract.dart';
import '../../chain_clients/abstract.dart';
import '../../models/chain_enum.dart';
import '../../models/dex_enum.dart';
import '../../utils/utils.dart';
import 'contracts/factory.dart';
import 'contracts/pair.dart';
import 'contracts/router.dart';

// Swap functions in UniSwap:
// https://docs.uniswap.org/protocol/V2/reference/smart-contracts/router-02
class PancakeSwap2Dex extends AbstractDex {
  final PancakeSwap2FactoryDeployedContract factoryContract;
  final PancakeSwap2RouterDeployedContract routerContract;
  int get id => 1;
  ChainEnum get chainEnum => ChainEnum.bsc;
  DexEnum get dexEnum => DexEnum.pancakeswap;
  String get name => 'PancakeSwap';

  static const _swapEventHash = '0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822';
  static final _swapEvent = PancakeSwap2PairDeployedContract.abiStatic.events.singleWhere((element) => element.name == 'Swap');

  static const _ttlSeconds = 20;

  @override
  int get ttlSeconds => _ttlSeconds;

  PancakeSwap2Dex.mainnet(AbstractChainClient client) :
      factoryContract = PancakeSwap2FactoryDeployedContract.mainnet(),
      routerContract = PancakeSwap2RouterDeployedContract.mainnet(),
      super(
        client: client,
      );

  @override
  List<EthereumAddress> getOtherAddresses() {
    return [
      EthereumAddress.fromHex(BscMainnetClient.wbnbAddress),
      EthereumAddress.fromHex(BscMainnetClient.busdAddress),
    ];
  }

  @override
  Future<DexPairInfo> requestPairInfo(EthereumAddress addressA, EthereumAddress addressB) async {
    final address = await factoryContract.getPair(client, addressA, addressB);

    if (address.isNull) {
      return DexPairInfo.notExistent(addressA: addressA, addressB: addressB);
    }
    return requestPairInfoByAddress(address);
  }

  Future<DexPairInfo> requestPairInfoByAddress(EthereumAddress address) async {
    final contract = await PancakeSwap2PairDeployedContract.create(
      address: address,
      client: client,
    );

    return DexPairInfo<PancakeSwap2PairDeployedContract>(
      lpAddress: address,
      contract: contract,
      addressA: contract.contract0.address,
      addressB: contract.contract1.address,
    );
  }

  @override
  Future<LiquidityPoolInfo> requestLiquidityPoolInfo(DexPairInfo pairInfo, {
    BlockNum? atBlock,
    bool forceLive = false,
  }) async {
    final reserves = await pairInfo.contract!.getReserves(
      client,
      atBlock: atBlock,
      forceLive: forceLive,
    );

    return LiquidityPoolInfo(
      reserves: reserves,
    );
  }

  @override
  Future<void> updateUsdNativeConverter() async {
    final usdAddress = client.usdStableCoinAddress;
    if (usdAddress == null) return null;

    final pairInfo = await getPairInfo(client.nativeTokenAddress, usdAddress);
    if (!pairInfo.isDeployed) return null;

    final reserves = await pairInfo.contract!.getReserves(client);
    final converter = await getUsdNativeConverter();
    converter.setReserves(
      usd: reserves.getBigIntByToken(usdAddress),
      native: reserves.getBigIntByToken(client.nativeTokenAddress),
    );
  }

  @override
  Future<double?> requestTokenUsdPrice(EthereumAddress address, {BlockNum? atBlock}) async {
    final usdAddress = client.usdStableCoinAddress;
    if (usdAddress == null) return null;
    if (address == usdAddress) return 1;

    final pairInfo = await getPairInfo(address, usdAddress);
    if (!pairInfo.isDeployed) return null;

    final reserves = await pairInfo.contract!.getReserves(client, atBlock: atBlock);
    if (reserves.isEmpty) return null;

    return reserves.getDoubleByToken(usdAddress) / reserves.getDoubleByToken(address);
  }

  SwapLog? parseSwapLog(FilterEvent log) {
    if (log.topics?.first != _swapEventHash) return null;

    final decoded = _swapEvent.decodeResults(log.topics!, log.data!);

    return SwapLog(
      amount0In: decoded[1],
      amount1In: decoded[2],
      amount0Out: decoded[3],
      amount1Out: decoded[4],
    );
  }

  @override
  List<EthereumAddress> getSpenderAddresses() {
    return [routerContract.address];
  }
}
