import 'dart:io';

import 'package:yaml/yaml.dart';

import 'transaction_sender_config.dart';
import '../models/chain_enum.dart';

class TransactionSenderConfigReader {
  static const fileName = 'keys.yaml';

  List<TransactionSenderConfig> getByChain(ChainEnum chainEnum) {
    final file = File(fileName);
    final content = file.readAsStringSync();
    final map = loadYaml(content) as YamlMap;

    final result = <TransactionSenderConfig>[];

    for (final key in map[chainEnum.name] ?? []) {
      result.add(
        TransactionSenderConfig(
          privateKey: key,
        ),
      );
    }

    return result;
  }
}
