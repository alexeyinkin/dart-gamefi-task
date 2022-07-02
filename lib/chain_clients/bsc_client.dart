import 'package:swap_bot/contracts/erc20.dart';
import 'package:web3dart/web3dart.dart';

import 'abstract.dart';
import '../dex/abstract.dart';
import '../dex/pancakeswap2/pancakeswap2.dart';
import '../models/chain_enum.dart';
import '../models/dex_enum.dart';
import '../utils/utils.dart';

abstract class AbstractBscClient extends AbstractChainClient {
  static const _symbol = 'BNB';
  static const _targetBlockDuration = Duration(seconds: 3);

  @override
  String get symbol => _symbol;

  @override
  Duration get targetBlockDuration => _targetBlockDuration;
}

class BscMainnetClient extends AbstractBscClient {
  final String mempoolUrl;
  final String liveUrl;
  final String archiveUrl;
  ChainEnum get chainEnum => ChainEnum.bsc;

  static const wbnbAddress = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';
  static const busdAddress = '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56';

  static const _addressesByAlias = {
    'busd': busdAddress,
    'bnb':  wbnbAddress,
    'wbnb': wbnbAddress,
  };

  BscMainnetClient({
    required this.mempoolUrl,
    required this.liveUrl,
    required this.archiveUrl,
  });

  @override
  String get name => 'BSC Mainnet';

  @override
  int get chainId => 56;

  @override
  final nativeTokenAddress = EthereumAddress.fromHex(wbnbAddress);

  @override
  final usdStableCoinAddress = EthereumAddress.fromHex(busdAddress);

  @override
  Web3Client createMempoolClient() {
    return Web3Client(mempoolUrl, createHttpClient());
  }

  @override
  Web3Client createClient() {
    return Web3Client(liveUrl, createHttpClient());
  }

  @override
  Web3Client createArchiveClient() {
    return Web3Client(archiveUrl, createHttpClient());
  }

  @override
  List<DexEnum> getDexEnums() {
    return [DexEnum.pancakeswap];
  }

  @override
  AbstractDex getDex(DexEnum dex) {
    switch (dex) {
      case DexEnum.pancakeswap:
        return PancakeSwap2Dex.mainnet(this);
    }

    throw Exception('Unknown dex: $dex');
  }

  @override
  Future<Erc20DeployedContract?> getContractByAlias(String alias) async {
    final str = _addressesByAlias[alias];
    if (str == null) return null;
    return Erc20DeployedContract.create(EthereumAddress.fromHex(str), this);
  }

  @override
  Future<EtherAmount> getRecommendedGasPrice() async {
    return EtherAmount.fromUnitAndValue(EtherUnit.gwei, 6);
  }
}
