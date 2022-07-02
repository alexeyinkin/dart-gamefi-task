import 'package:web3dart/web3dart.dart';

class TransactionSender {
  final Credentials credentials;
  final EthereumAddress walletAddress;
  int _nonce;

  TransactionSender({
    required this.credentials,
    required this.walletAddress,
    required int nonce,
  }) :
      _nonce = nonce;

  int getNonceAndIncrement() {
    return _nonce++;
  }
}
