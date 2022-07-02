class InOut {
  final BigInt amountIn;
  final BigInt amountOutMin;

  static final empty = InOut(
    amountIn: BigInt.zero,
    amountOutMin: BigInt.zero,
  );

  const InOut({
    required this.amountIn,
    required this.amountOutMin,
  });

  double get maxPrice => amountIn / amountOutMin;
  bool get isEmpty => amountIn == BigInt.zero;
}
