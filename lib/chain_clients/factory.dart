import 'abstract.dart';
import 'bsc_client.dart';
import '../config/config.dart';
import '../models/chain_enum.dart';

class ChainClientFactory {
  static AbstractChainClient create(Config config) {
    return createByChain(config, config.chain);
  }

  static AbstractChainClient createByChain(Config config, ChainEnum chain) {
    final chainConfig = config.chains[chain]!;
    switch (config.chain) {
      case ChainEnum.bsc:
        return BscMainnetClient(
          mempoolUrl: chainConfig.mempoolUrl,
          liveUrl:    chainConfig.liveUrl,
          archiveUrl: chainConfig.archiveUrl,
        );
    }

    throw Exception('Unknown chain: ${config.chain}');
  }
}
