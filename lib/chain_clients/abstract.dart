import 'package:meta/meta.dart';
import 'package:web3dart/web3dart.dart';

import '../dex/abstract.dart';
import '../contracts/erc20.dart';
import '../config/config.dart';
import '../config/transaction_sender_config.dart';
import '../models/chain_enum.dart';
import '../models/dex_enum.dart';
import 'transaction_sender.dart';

abstract class AbstractChainClient {
  Web3Client? _mempoolClient;
  Web3Client? _client;
  Web3Client? _archiveClient;
  String get name;
  ChainEnum get chainEnum;
  int get chainId;
  String get symbol;
  EthereumAddress get nativeTokenAddress;
  EthereumAddress? get usdStableCoinAddress;

  final transactionSenders = <TransactionSender>[];
  int _nextSenderIndex = 0;

  final _erc20ContractsByAddress = <EthereumAddress, Erc20DeployedContract>{};
  Erc20DeployedContract? _usdStableCoinContract;

  static const _maxGas = 1000000; // 1 million.

  static final _minAllowance = BigInt.from(10).pow(4 * 18); // 10k ETH.

  Future<void> setCredentials(List<TransactionSenderConfig> configs) async {
    for (final config in configs) {
      final credentials = EthPrivateKey.fromHex(config.privateKey);
      final walletAddress = await credentials.extractAddress();

      final sender = TransactionSender(
        credentials: credentials,
        walletAddress: walletAddress,
        nonce: await client.getTransactionCount(walletAddress),
      );

      transactionSenders.add(sender);
    }
  }

  int getNextSenderIndex() {
    if (_nextSenderIndex >= transactionSenders.length) {
      throw Exception('No credentials loaded to sign transactions.');
    }

    final result = _nextSenderIndex;
    _nextSenderIndex = (_nextSenderIndex + 1) % transactionSenders.length;
    return result;
  }

  Future<Erc20DeployedContract> getErc20ContractByAddress(EthereumAddress address) async {
    if (!_erc20ContractsByAddress.containsKey(address)) {
      _erc20ContractsByAddress[address] = await Erc20DeployedContract.create(address, this);
    }
    return _erc20ContractsByAddress[address]!;
  }

  Future<Erc20DeployedContract> getNativeTokenContract() async {
    return getErc20ContractByAddress(nativeTokenAddress);
  }

  bool isUsdStableCoin(EthereumAddress address) {
    return address == usdStableCoinAddress;
  }

  Future<Erc20DeployedContract?> getUsdStableCoinContract() async {
    if (_usdStableCoinContract == null) {
      if (usdStableCoinAddress == null) return null;
      _usdStableCoinContract = await Erc20DeployedContract.create(usdStableCoinAddress!, this);
    }
    return _usdStableCoinContract;
  }

  @protected
  Web3Client createMempoolClient();

  @protected
  Web3Client createClient();

  @protected
  Web3Client createArchiveClient();

  Web3Client get mempoolClient {
    if (_mempoolClient == null) {
      _mempoolClient = createMempoolClient();
    }
    return _mempoolClient!;
  }

  Web3Client get client {
    if (_client == null) {
      _client = createClient();
    }
    return _client!;
  }

  Web3Client get archiveClient {
    if (_archiveClient == null) {
      _archiveClient = createArchiveClient();
    }
    return _archiveClient!;
  }

  Web3Client getClient({required bool live}) {
    return live ? client : archiveClient;
  }

  Web3Client getClientByBlockNum(BlockNum? blockNum, {bool forceLive = false}) {
    if (forceLive) return client;
    return blockNum == null ? client : archiveClient;
  }

  List<DexEnum> getDexEnums();
  AbstractDex getDex(DexEnum dex);
  Duration get targetBlockDuration;

  List<AbstractDex> getDexes() {
    final result = <AbstractDex>[];

    for (final dexEnum in getDexEnums()) {
      result.add(getDex(dexEnum));
    }

    return result;
  }

  Future<String> formatSymbolPath(List<EthereumAddress> path) async {
    final contracts = <Erc20DeployedContract>[];

    for (final address in path) {
      contracts.add(await getErc20ContractByAddress(address));
    }

    return contracts.map((c) => c.symbol).join(' → ');
  }

  Future<Erc20DeployedContract> getOtherContract(Config config) async {
    final otherAddressString = config.otherAddressString;
    if (otherAddressString == null) return getNativeTokenContract();

    return
        await _getContractByAddress(otherAddressString) ??
        await getContractByAlias(otherAddressString) ??
        (throw Exception('Unrecognized other address: $otherAddressString'));
  }

  Future<Erc20DeployedContract?> _getContractByAddress(String hexString) async {
    try {
      final address = EthereumAddress.fromHex(hexString);
      return getErc20ContractByAddress(address);
    } catch (ex) {
      return null;
    }
  }

  Future<Erc20DeployedContract?> getContractByAlias(String alias);

  Future<List<SentTransaction>> approveIfNot({
    required EthereumAddress token,
    required EthereumAddress spender,
  }) async {
    final result = <SentTransaction>[];
    final contract = await getErc20ContractByAddress(token);

    for (final sender in transactionSenders) {
      final tx = await _approveOwnerIfNot(contract: contract, token: token, owner: sender, spender: spender);
      if (tx != null) result.add(tx);
    }

    return result;
  }

  Future<SentTransaction?> _approveOwnerIfNot({
    required Erc20DeployedContract contract,
    required EthereumAddress token,
    required TransactionSender owner,
    required EthereumAddress spender,
  }) async {
    final allowance = await contract.allowance(this, owner: owner.walletAddress, spender: spender);

    if (allowance >= _minAllowance) return null;

    return await contract.approve(
      this,
      owner,
      spender: spender,
      value: _minAllowance * BigInt.from(2),
    );
  }

  Future<SentTransaction> callContract({
    required TransactionSender transactionSender,
    required DeployedContract contract,
    required String functionName,
    required List parameters,
    EtherAmount? gasPrice,
  }) async {
    final transaction = Transaction.callContract(
      contract: contract,
      function: contract.function(functionName),
      parameters: parameters,
      from: transactionSender.walletAddress,
      maxGas: _maxGas,
      gasPrice: gasPrice ?? await getRecommendedGasPrice(),
      value: EtherAmount.zero(),
      nonce: transactionSender.getNonceAndIncrement(),
    );

    final hash = await mempoolClient.sendTransaction(
      transactionSender.credentials,
      transaction,
      chainId: chainId,
    );

    return SentTransaction(
      transaction: transaction,
      hash: hash,
      deviceDateTime: DateTime.now().toUtc(),
      indexInApp: SentTransaction.getNextIndexInApp(),
    );
  }

  Future<EtherAmount> getRecommendedGasPrice();

  // TODO: A better awaiting. Maybe create TransactionsBloc and add awaitAll there.
  Future<Map<String, TransactionReceipt>> awaitTransactions(List<String> hashes) async {
    final result = <String, TransactionReceipt>{};

    for (final hash in hashes) {
      while (true) {
        final receipt = await client.getTransactionReceipt(hash);

        if (receipt != null) {
          result[hash] = receipt;
          break;
        }

        await Future.delayed(const Duration(seconds: 1));
      }
    }

    return result;
  }

  Future<DateTime> getBlockTimestamp(int block) async {
    final info = await client.getBlockInformation(blockNumber: BlockNum.exact(block).toBlockParam());
    return info.timestamp;
  }
}

class SentTransaction {
  final Transaction transaction;
  final String hash;
  final DateTime deviceDateTime;
  final int indexInApp;

  static int _nextIndexInApp = 0;
  static getNextIndexInApp() => _nextIndexInApp++;

  SentTransaction({
    required this.transaction,
    required this.hash,
    required this.deviceDateTime,
    required this.indexInApp,
  });
}

class SentTradeTransaction extends SentTransaction {
  final List<EthereumAddress> path;
  final BigInt amountIn;
  final BigInt amountMinOut;

  SentTradeTransaction({
    required Transaction transaction,
    required String hash,
    required DateTime deviceDateTime,
    required int indexInApp,
    required this.path,
    required this.amountIn,
    required this.amountMinOut,
  }) : super(
    transaction: transaction,
    hash: hash,
    deviceDateTime: deviceDateTime,
    indexInApp: indexInApp,
  );
}
