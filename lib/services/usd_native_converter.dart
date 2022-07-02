import 'rate_converter.dart';

class UsdNativeConverter {
  final converter = RateConverter();

  void setReserves({
    required BigInt usd,
    required BigInt native,
  }) {
    converter.setReserves(a: usd, b: native);
  }

  BigInt usdToNative(BigInt usd) => converter.aToB(usd);
  BigInt nativeToUsd(BigInt native) => converter.bToA(native);
}
