import 'package:logging/logging.dart';
import 'package:web3dart/web3dart.dart';

import '../chain_clients/abstract.dart';
import '../chain_clients/transaction_sender.dart';
import '../errors/retry.dart';
import '../utils/utils.dart';

class Erc20DeployedContract extends DeployedContract {
  final String name;
  final double totalSupply;
  final int decimals;
  final String symbol;

  Erc20DeployedContract({
    required ContractAbi abi,
    required EthereumAddress address,
    required this.name,
    required this.totalSupply,
    required this.decimals,
    required this.symbol,
  }) : super(abi, address);

  static const _json = '[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]';
  static final _logger = Logger('Erc20DeployedContract');

  // TODO: Find non-caching calls to this, cache.
  static Future<Erc20DeployedContract> create(EthereumAddress address, AbstractChainClient client) async {
    final abi = ContractAbi.fromJson(_json, '');
    final c = DeployedContract(abi, address);

    _logger.info('Getting ERC-20 contract at $address');

    try {
      return await _createWithClient(address, client.client, abi, c);
    } on ExceptionWithInnerAndStackTrace catch (ex) {
      _logger.severe('Cannot get ERC-20 contract at $address', ex.inner, ex.stackTrace);
      rethrow;
    }
  }

  static Future<Erc20DeployedContract> _createWithClient(EthereumAddress address, Web3Client client, ContractAbi abi, DeployedContract c) async {
    final decimalsBigInt = await getConstant<BigInt>(client, c, 'decimals');
    final decimals = decimalsBigInt.toInt();
    final totalSupply = await getConstant<BigInt>(client, c, 'totalSupply');

    return Erc20DeployedContract(
      abi:          abi,
      address:      address,
      name:         await getConstant<String>(client, c, 'name'),
      totalSupply:  totalSupply / BigInt.from(10).pow(decimals),
      decimals:     decimals,
      symbol:       await getConstant<String>(client, c, 'symbol'),
    );
  }

  double intToDouble(BigInt amount) {
    return amount / BigInt.from(10).pow(decimals);
  }

  BigInt doubleToInt(double amount) {
    return BigInt.from(amount * BigInt.from(10).pow(decimals).toDouble());
  }

  Future<BigInt> balanceOf({
    required AbstractChainClient client,
    required EthereumAddress address,
    BlockNum? atBlock,
  }) async {
    final fn = () => client.client.call(
      contract: this,
      function: function('balanceOf'),
      params: [address],
      atBlock: atBlock,
    );

    final response = await myRetry(fn);
    return response[0] as BigInt;
  }

  Future<BigInt> allowance(AbstractChainClient client, {
    required EthereumAddress owner,
    required EthereumAddress spender,
  }) async {
    final response = await client.client.call(
      contract: this,
      function: function('allowance'),
      params: [owner, spender],
    );
    return response[0] as BigInt;
  }

  Future<SentTransaction> approve(AbstractChainClient client, TransactionSender transactionSender, {
    required EthereumAddress spender,
    required BigInt value,
  }) async {
    return client.callContract(
      contract: this,
      transactionSender: transactionSender,
      functionName: 'approve',
      parameters: [
        spender,
        value,
      ],
    );
  }
}
