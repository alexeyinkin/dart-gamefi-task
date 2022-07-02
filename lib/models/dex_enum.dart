enum DexEnum {
  pancakeswap,
}

abstract class DexIds {
  static const pancakeswap = 1;
}

DexEnum getDexById(int id) {
  switch (id) {
    case DexIds.pancakeswap: return DexEnum.pancakeswap;
  }
  throw Exception('Unknown dex id: $id');
}

int getDexId(DexEnum dex) {
  switch (dex) {
    case DexEnum.pancakeswap: return DexIds.pancakeswap;
  }
  throw Exception('Unknown dex: $dex');
}
