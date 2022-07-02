import 'package:web3dart/web3dart.dart';

import '../chain_clients/abstract.dart';

class NativeBalanceRequester {
  final AbstractChainClient client;

  NativeBalanceRequester(this.client);

  Future<EtherAmount> getBalance(EthereumAddress address) {
    return client.client.getBalance(address);
  }
}
