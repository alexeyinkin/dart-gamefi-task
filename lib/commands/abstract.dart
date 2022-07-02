import 'dart:io';

import 'package:meta/meta.dart';

import '../chain_clients/abstract.dart';
import '../chain_clients/factory.dart';
import '../contracts/erc20.dart';
import '../dex/abstract.dart';
import '../formatters/double.dart';
import '../config/config.dart';
import '../config/reader.dart';
import '../config/transaction_sender_config.dart';
import '../config/transaction_sender_config_reader.dart';

abstract class AbstractCommand {
  late final Config config;
  late final AbstractChainClient client;
  late final AbstractDex dex;
  late DexPairInfo pairInfo;
  late final Erc20DeployedContract tokenContract;
  late final Erc20DeployedContract otherContract;
  final wholeDoubleFormatter = WholeDoubleFormatter();
  final centDoubleFormatter = CentDoubleFormatter();

  Future<void> runBase() async {
    config = ConfigReader.read();
    client = ChainClientFactory.create(config);
    dex = client.getDex(config.dex);
    client.setCredentials(_getCredentials());

    tokenContract = await Erc20DeployedContract.create(config.tokenAddress, client);
    otherContract = await client.getOtherContract(config);

    pairInfo = await dex.getPairInfo(config.tokenAddress, otherContract.address);

    await printHeader();
    stdout.writeln();
    await run();
  }

  List<TransactionSenderConfig> _getCredentials() {
    try {
      return TransactionSenderConfigReader().getByChain(client.chainEnum);
    } catch (ex) {
      return const [];
    }
  }

  @protected
  Future<void> printHeader() async {}

  @protected
  Future<void> run();

  void printDex() {
    stdout.write('Chain:      ${client.name}\n');
    stdout.write('DEX:        ${dex.name}\n');
  }

  Future<void> checkAndPrintAccounts() async {
    if (client.transactionSenders.isEmpty) {
      stdout.write('Accounts:   Cannot load from keys.yaml!\n');
      return;
    }

    final converter = await dex.getUsdNativeConverter();

    for (final sender in client.transactionSenders) {
      final parts = <String>[];

      parts.add(sender == client.transactionSenders.first ? 'Accounts:   ' : ' ' * 12);
      parts.add(sender.walletAddress.hexEip55);

      final nativeContract = await client.getNativeTokenContract();
      final nativeInt = await nativeContract.balanceOf(client: client, address: sender.walletAddress);
      final nativeDouble = nativeContract.intToDouble(nativeInt);

      parts.add('   ');
      parts.add(centDoubleFormatter.format(nativeDouble, symbol: nativeContract.symbol));

      final usdContract = (await client.getUsdStableCoinContract())!;
      final usdInt = converter.nativeToUsd(nativeInt);
      final usdDouble = usdContract.intToDouble(usdInt);

      parts.add(' = ');
      parts.add(centDoubleFormatter.format(usdDouble, symbol: r'$'));
      stdout.write(parts.join() + '\n');

      if (usdDouble < config.amount.usdIn) {
        throw Exception('Insufficient balance: got $usdDouble \$, need ${config.amount.usdIn} \$');
      }
    }
  }

  void printSingleToken({required bool trade}) {
    final prefix = trade ? 'Will buy:   ' : 'Pair:       ';
    stdout.write('$prefix${tokenContract.symbol} ${tokenContract.address} for ${otherContract.symbol}\n');

    if (pairInfo.isDeployed) {
      stdout.write('LP Token:   ${pairInfo.lpAddress!.hex}\n');
    } else {
      stdout.write('LP Token:   Not Yet Created\n');
    }
  }

  Future<void> printLimits() async {
    final converter = await dex.getUsdNativeConverter();
    final nativeInInt = converter.usdToNative(config.amount.usdInInt);

    final nativeContract = await client.getNativeTokenContract();
    final usdContract = await client.getUsdStableCoinContract();

    final nativeInFormatted = centDoubleFormatter.format(nativeContract.intToDouble(nativeInInt), symbol: nativeContract.symbol);
    final usdFormatted = centDoubleFormatter.format(usdContract!.intToDouble(config.amount.usdInInt), symbol: r'$');

    stdout.write('Use:        $nativeInFormatted ($usdFormatted)\n');

    final maxPriceInUsdFormatted = centDoubleFormatter.format(config.amount.limits.maxPriceInUsd, symbol: r'$');
    stdout.write('Max Price:  $maxPriceInUsdFormatted\n');

    final slippageFormatted = (config.amount.limits.slippage * 100).ceil();
    stdout.write('Slippage:   $slippageFormatted%\n');

    final maxPoolShareFormatted = (config.amount.limits.maxPoolShare * 100).ceil();
    stdout.write('Max Share:  $maxPoolShareFormatted% of Pool\n');
  }

  void printTime() {
    stdout.write('Time:       ${DateTime.now().toUtc()}\n');
  }

  void initTerminal() {
    try {
      stdin
        ..lineMode = false
        ..echoMode = false
        ..listen(onKeyPressed)
      ;
    } catch (ex) {
      stdout.write('Running not in terminal. Control keys disabled.\n');
    }
  }

  void onKeyPressed(List<int> codes) {}
}
