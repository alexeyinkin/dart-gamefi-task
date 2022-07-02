class RateConverter {
  BigInt _reservesA = BigInt.zero;
  BigInt _reservesB = BigInt.zero;
  double _aPerB = double.nan;
  double _bPerA = double.nan;

  void setReserves({
    required BigInt a,
    required BigInt b,
  }) {
    _reservesA = a;
    _reservesB = b;
    _aPerB = _reservesA / _reservesB;
    _bPerA = _reservesB / _reservesA;
  }

  BigInt aToB(BigInt a) => BigInt.from(a.toDouble() / _aPerB);
  BigInt bToA(BigInt b) => BigInt.from(b.toDouble() / _bPerA);
}
