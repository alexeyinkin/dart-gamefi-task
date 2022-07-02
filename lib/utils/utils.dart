import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:mysql1/mysql1.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../errors/retry.dart';

const myMaxInt = 999999999999999999;

extension Single on Results {
  T getSingle<T>() => first.values!.first as T;
  T? getSingleOrNull<T>() => isEmpty ? null : getSingle<T>();
}

// TODO: Submit to web3dart package.
extension IsNull on EthereumAddress {
  bool get isNull {
    return hexNo0x == '0' * 40;
  }
  bool get isNotNull => !isNull;
}

EthereumAddress? ethereumAddressFromHexOrNull(String? hex) {
  if (hex == null) return null;
  return EthereumAddress.fromHex(hex);
}

extension RequireFunctionBySelector on ContractAbi {
  ContractFunction? getFunctionBySelector(String selector) {
    return functions.singleWhereOrNull((f) => bytesToHex(f.selector) == selector);
  }
}

extension RequireTransactionReceipt on Web3Client {
  Future<TransactionReceipt> requireTransactionReceipt(String hash) async {
    final fn = () => getTransactionReceipt(hash);

    for (int attempts = 5; --attempts >= 0; ) {
      final result = await myRetry(fn);
      if (result != null) return result;
      await Future.delayed(Duration(seconds: 1));
    }
    throw Exception('Unexpected null receipt for tx $hash');
  }
}

extension ToStringToSeconds on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  String toStringToSeconds() {
    String y = _fourDigits(year);
    String m = _twoDigits(month);
    String d = _twoDigits(day);
    String h = _twoDigits(hour);
    String min = _twoDigits(minute);
    String sec = _twoDigits(second);

    return "$y-$m-$d $h:$min:$sec";
  }

  String toTimeStringToSeconds() {
    String h = _twoDigits(hour);
    String min = _twoDigits(minute);
    String sec = _twoDigits(second);

    return "$h:$min:$sec";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "${n}";
    return "0${n}";
  }

  static String _fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }
}

extension NumMap<K, V extends num> on Map<K, V> {
  Map<K, double> operator / (num denominator) {
    return map((key, value) => MapEntry<K, double>(key, value / denominator));
  }
}

DateTime dateTimeFromSecondsSinceEpoch(int seconds) {
  try {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toUtc();
  } catch (ex) {
    return DateTime.utc(3000, 1, 1);
  }
}

DateTime? dateTimeOrNullFromSecondsSinceEpoch(int? seconds) {
  if (seconds == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toUtc();
}

extension DurationOperators on Duration {
  Duration operator /(num factor) {
    final microseconds = (inMicroseconds / factor).floor();
    return Duration(microseconds: max(microseconds, 1));
  }
}

extension Shorten on String {
  String shortenIfLonger(int length) {
    return this.length < length
        ? this
        : this.substring(0, length);
  }
}

Future<T> getConstant<T>(Web3Client client, DeployedContract contract, String name) async {
  final fn = () => client.call(
    contract: contract,
    function: contract.function(name),
    params: [],
  );
  final result = await myRetry(fn);
  return result[0];
}

BigInt maxBigInt(BigInt a, BigInt b) => a > b ? a : b;
BigInt minBigInt(BigInt a, BigInt b) => a < b ? a : b;

int toIntIfNot(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.floor();
  if (value is String) return int.parse(value);
  throw Exception('Cannot convert $value to int.');
}

double toDoubleIfNot(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.parse(value);
  throw Exception('Cannot convert $value to double.');
}

List<int>? toIntListOrNull(dynamic value) {
  if (value == null) return null;

  final result = <int>[];
  for (final one in value) {
    result.add(toIntIfNot(one));
  }
  return result;
}

Client createHttpClient() {
  final inner = HttpClient();
  inner.connectionTimeout = Duration(seconds: 10);
  final client = IOClient(inner);
  return client;
}
