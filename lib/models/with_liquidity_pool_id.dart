abstract class WithLiquidityPoolId {
  int get liquidityPoolId;

  static Map<int, List<T>> mapByPoolIds<T extends WithLiquidityPoolId>(Iterable<T> items) {
    final result = <int, List<T>>{};

    for (final item in items) {
      final lpId = item.liquidityPoolId;
      if (!result.containsKey(lpId)) {
        result[lpId] = <T>[];
      }
      result[lpId]!.add(item);
    }

    return result;
  }
}
