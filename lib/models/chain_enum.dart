enum ChainEnum {
  bsc,
  eth,
  polygon,
}

abstract class ChainIds {
  static const eth = 1;
  static const bsc = 56;
  static const polygon = 137;
}

ChainEnum getChainById(int id) {
  switch (id) {
    case ChainIds.bsc: return ChainEnum.bsc;
    case ChainIds.eth: return ChainEnum.eth;
    case ChainIds.polygon: return ChainEnum.polygon;
  }
  throw Exception('Unknown chain id: $id');
}

int getChainId(ChainEnum chain) {
  switch (chain) {
    case ChainEnum.bsc: return ChainIds.bsc;
    case ChainEnum.eth: return ChainIds.eth;
    case ChainEnum.polygon: return ChainIds.polygon;
  }
  throw Exception('Unknown chain: $chain');
}
