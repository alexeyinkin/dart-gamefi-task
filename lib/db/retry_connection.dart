import 'package:mysql1/mysql1.dart';

import '../errors/retry.dart';

class RetryMySqlConnection implements MySqlConnection {
  final MySqlConnection inner;

  RetryMySqlConnection(this.inner);

  @override
  Future close() {
    return inner.close();
  }

  @override
  Future<Results> query(String sql, [List<Object?>? values]) async {
    final fn = () => inner.query(sql, values);
    return await myRetry(fn);
  }

  @override
  Future<List<Results>> queryMulti(String sql, Iterable<List<Object?>> values) async {
    final fn = () => inner.queryMulti(sql, values);
    return await myRetry(fn);
  }

  @override
  Future transaction(Function queryBlock) async {
    final fn = () => inner.transaction(queryBlock);
    return await myRetry(fn);
  }
}
