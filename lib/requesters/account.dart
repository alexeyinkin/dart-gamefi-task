import 'dart:io';

import 'package:web3dart/web3dart.dart';

class AccountRequester {
  static const fileName = 'pkey.txt';

  static Credentials getCredentials() {
    final privateKey = File(fileName).readAsStringSync();
    return EthPrivateKey.fromHex(privateKey);
  }
}
