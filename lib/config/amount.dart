import 'limits.dart';
import '../utils/utils.dart';

class AmountConfig {
  final double usdIn;
  final BigInt usdInInt;
  final LimitsConfig limits;

  static final empty = AmountConfig._(
    usdIn: 0,
    limits: LimitsConfig.empty,
    usdDecimals: 0,
  );

  AmountConfig._({
    required this.usdIn,
    required this.limits,
    required int usdDecimals,
  }) :
      usdInInt = BigInt.from(BigInt.from(10).pow(usdDecimals).toDouble() * usdIn);

  factory AmountConfig.fromMap(Map map, {required int nativeDecimals, required int usdDecimals}) {
    return AmountConfig._(
      usdIn: toDoubleIfNot(map['usdIn']),
      limits: LimitsConfig.fromMap(map['limits']),
      usdDecimals: usdDecimals,
    );
  }
}
