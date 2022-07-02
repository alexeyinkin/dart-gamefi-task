import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';
import 'package:retry/retry.dart';
import 'package:web3dart/json_rpc.dart';

final _retryLogger = Logger('myRetry');

Future<T> myRetry<T>(Future<T> Function() fn) async {
  return retry(
    () => rethrowErrorAsException(fn),
    onRetry: (Exception ex) {
      if (ex is ExceptionWithInnerAndStackTrace) {
        _retryLogger.warning(ex.inner.toString(), ex.inner, ex.stackTrace);
      }
    },
    retryIf: (Exception e) {
      if (e is ExceptionWithStackTrace) {
        final inner = e.inner;
        if (inner is ClientException) return true;
        if (inner is FormatException) return true;      // Parsing web3dart response on connection problems.
        if (inner is HandshakeException) return true;
        if (inner is RPCError) return true;
        if (inner is SocketException) return true;
        if (inner is TimeoutException) return true;
      }

      if (e is ErrorException) {
        final error = e.error;
        if (error is TypeError) return true; // Null in web3dart response while expecting Map.
        if (error is MySqlProtocolError) return true;

        if (error is RangeError) return false; // PancakeSwap pair returns empty reserves before liquidity.
      }

      return false;
    }
  );
}

Future<T> rethrowErrorAsException<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on Exception catch (ex, stackTrace) {
    throw ExceptionWithStackTrace(innerException: ex, stackTrace: stackTrace);
  } on Error catch (error, stackTrace) {
    throw ErrorException(error: error, stackTrace: stackTrace);
  }
}

abstract class ExceptionWithInnerAndStackTrace implements Exception {
  /// Error or Exception.
  dynamic get inner;
  StackTrace get stackTrace;
}

class ExceptionWithStackTrace implements ExceptionWithInnerAndStackTrace {
  final Exception innerException;

  @override
  Exception get inner => innerException;

  @override
  final StackTrace stackTrace;

  ExceptionWithStackTrace({
    required this.innerException,
    required this.stackTrace,
  });
}

class ErrorException implements ExceptionWithInnerAndStackTrace {
  final Error error;

  @override
  Error get inner => error;

  @override
  final StackTrace stackTrace;

  ErrorException({
    required this.error,
    required this.stackTrace,
  });
}
