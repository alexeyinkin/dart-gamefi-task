import 'package:mysql1/mysql1.dart';

import 'db_connection_provider.dart';
import '../models/reserves.dart';
import '../utils/utils.dart';

class ReservesDbService {
  Future<void> save(Reserves reserves) async {
    if (reserves.id == null) {
      return _insert(reserves);
    }
    throw UnimplementedError('Update not implemented');
  }

  Future<void> _insert(Reserves reserves) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = '''
      INSERT INTO Reserves(
        liquidityPoolId,
        `block`,
        `dateTime`,
        reserve0,
        reserve1,
        halfPoolUsdValue
      ) VALUES (?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE id = id
    ''';
    final result = await connection.query(sql, [
      reserves.liquidityPoolId,
      reserves.block,
      reserves.dateTime.secondsSinceEpoch,
      reserves.reserve0,
      reserves.reserve1,
      reserves.halfPoolUsdValue,
    ]);

    reserves.id = result.insertId;
  }

  Future<Reserves?> getByBlockAndPool(int block, int liquidityPoolId) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = '''
      SELECT * FROM Reserves
      WHERE
        `block` = ? AND
        `liquidityPoolId` = ?
    ''';
    final results = await connection.query(sql, [
      block,
      liquidityPoolId,
    ]);

    return _getFromRowIfAny(results);
  }

  Future<Iterable<Reserves>> getByProjectId(int projectId) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = '''
      SELECT *
      FROM
        Reserves r
        INNER JOIN LiquidityPool lp ON r.liquidityPoolId = lp.id
      WHERE
        lp.projectId = ?
      ORDER BY
        lp.id,
        r.`block`
    ''';
    final results = await connection.query(sql, [
      projectId,
    ]);

    return _getAllFromRows(results);
  }

  Iterable<Reserves> _getAllFromRows(Results results) {
    return results.map((row) => _getFromRow(row));
  }

  Reserves? _getFromRowIfAny(Results results) {
    for (final row in results) {
      return _getFromRow(row);
    }
    return null;
  }

  Reserves _getFromRow(ResultRow row) {
    final fields = row.fields;

    return Reserves(
      id: fields['id'],
      liquidityPoolId: fields['liquidityPoolId'],
      block: fields['block'],
      dateTime: dateTimeFromSecondsSinceEpoch(fields['dateTime']),
      reserve0: fields['reserve0'],
      reserve1: fields['reserve1'],
      halfPoolUsdValue: fields['halfPoolUsdValue'],
    );
  }

  Future<int?> getLastBlockByLiquidityPool(int liquidityPoolId) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = 'SELECT MAX(`block`) FROM Reserves WHERE liquidityPoolId = ?';
    final results = await connection.query(sql, [
      liquidityPoolId,
    ]);
    return results.getSingleOrNull<int?>();
  }
}
