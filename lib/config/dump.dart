import '../utils/utils.dart';

class DumpConfig {
  final int reservesBlocks;
  final List<int> transactionsBlocks;

  DumpConfig._({
    required this.reservesBlocks,
    required this.transactionsBlocks,
  });

  static DumpConfig? fromMapOrNull(Map? map) {
    if (map == null) return null;

    final transactionsBlocks = toIntListOrNull(map['transactionsBlocks']);

    if (transactionsBlocks == null || transactionsBlocks.length != 2) {
      throw Exception('transactionsBlocks must be a list of 2 ints.');
    }

    return DumpConfig._(
      reservesBlocks:     map['reservesBlocks'] as int,
      transactionsBlocks: transactionsBlocks,
    );
  }
}
