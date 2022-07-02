import '../utils/utils.dart';

class LimitsConfig {
  final double slippage;
  final double maxPriceInUsd;
  final double maxPoolShare;

  static const empty = LimitsConfig._(
    slippage: 0,
    maxPriceInUsd: 0,
    maxPoolShare: 0,
  );

  const LimitsConfig._({
    required this.slippage,
    required this.maxPriceInUsd,
    required this.maxPoolShare,
  });

  factory LimitsConfig.fromMap(Map map) {
    return LimitsConfig._(
      slippage:         toDoubleIfNot(map['slippage']),
      maxPriceInUsd:    toDoubleIfNot(map['maxPriceInUsd']),
      maxPoolShare:     toDoubleIfNot(map['maxPoolShare']),
    );
  }
}
