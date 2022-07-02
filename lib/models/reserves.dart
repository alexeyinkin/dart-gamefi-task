import 'with_liquidity_pool_id.dart';

class Reserves implements WithLiquidityPoolId {
  int? id;
  final int liquidityPoolId;
  final int block;
  final DateTime dateTime;
  final double reserve0;
  final double reserve1;
  final double halfPoolUsdValue;

  Reserves({
    required this.id,
    required this.liquidityPoolId,
    required this.block,
    required this.dateTime,
    required this.reserve0,
    required this.reserve1,
    required this.halfPoolUsdValue,
  });

  double getReserveByIndex(int index) {
    switch (index) {
      case 0: return reserve0;
      case 1: return reserve1;
    }
    throw Exception('Index out of bounds [0, 1]: $index');
  }

  double getTokenUsdPriceByIndex(int index) {
    switch (index) {
      case 0: return halfPoolUsdValue / reserve0;
      case 1: return halfPoolUsdValue / reserve1;
    }
    throw Exception('Index out of bounds [0, 1]: $index');
  }
}
