import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:web3dart/web3dart.dart';

import 'db_connection_provider.dart';
import '../models/chain_enum.dart';
import '../models/project.dart';
import '../utils/utils.dart';

class ProjectDbService {
  Future<void> save(Project project) async {
    if (project.id == null) {
      return _insert(project);
    }
    return _update(project);
  }

  Future<void> _insert(Project project) async {
    final now = DateTime.now();
    final timestamp = now.secondsSinceEpoch;
    final connection = await DbConnectionProvider.getConnection();
    final sql = '''
      INSERT INTO Project(
        launchpadId,
        chainId,
        idInLaunchpad,
        title,
        symbol,
        dateTimeInserted,
        dateTimeUpdated,
        tokenAddress,
        dateTimePoolCreationEstimate,
        status,
        firstLiquidityBlock,
        lockPid,
        presaleUsdPrice,
        initialDexUsdPrice,
        xAfterStopLoss,
        tradable
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''';
    final result = await connection.query(sql, [
      project.launchpadId,
      getChainId(project.chain),
      project.idInLaunchpad,
      project.title,
      project.symbol,
      timestamp,
      timestamp,
      project.tokenAddress?.hex,
      project.dateTimePoolCreationEstimate?.secondsSinceEpoch,
      project.status.name,
      project.firstLiquidityBlock,
      project.lockPid,
      project.presaleUsdPrice,
      project.initialDexUsdPrice,
      project.xAfterStopLoss,
      project.tradable ? 1 : 0,
    ]);

    project.id = result.insertId;
    project.dateTimeInserted = now;
    project.dateTimeUpdated = now;
  }

  Future<void> _update(Project project) async {
    final now = DateTime.now();
    final timestamp = now.secondsSinceEpoch;
    final connection = await DbConnectionProvider.getConnection();
    final sql = '''
      UPDATE Project SET
        launchpadId = ?,
        chainId = ?,
        idInLaunchpad = ?,
        title = ?,
        symbol = ?,
        dateTimeUpdated = ?,
        tokenAddress = ?,
        dateTimePoolCreationEstimate = ?,
        status = ?,
        firstLiquidityBlock = ?,
        lockPid = ?,
        presaleUsdPrice = ?,
        initialDexUsdPrice = ?,
        xAfterStopLoss = ?,
        tradable = ?
      WHERE id = ?
    ''';
    await connection.query(sql, [
      project.launchpadId,
      getChainId(project.chain),
      project.idInLaunchpad,
      project.title,
      project.symbol,
      timestamp,
      project.tokenAddress?.hex,
      project.dateTimePoolCreationEstimate?.secondsSinceEpoch,
      project.status.name,
      project.firstLiquidityBlock,
      project.lockPid,
      project.presaleUsdPrice,
      project.initialDexUsdPrice,
      project.xAfterStopLoss,
      project.tradable ? 1 : 0,
      project.id,
    ]);

    project.dateTimeUpdated = now;
  }

  Future<void> lock(Project project) async {
    await _setPid(project, pid);
  }

  Future<void> unlock(Project project) async {
    await _setPid(project, null);
  }

  Future<void> _setPid(Project project, int? pid) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = 'UPDATE Project SET lockPid = ? WHERE id = ?';
    await connection.query(sql, [
      pid,
      project.id,
    ]);

    project.lockPid = pid;
  }

  Future<Project> requireById(int id) async {
    final result = await getById(id);
    if (result == null) throw Exception('Project not found: $id');
    return result;
  }

  Future<Project?> getById(int id) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = 'SELECT * FROM Project WHERE id = ?';
    final results = await connection.query(sql, [id]);

    return _getFromRowIfAny(results);
  }

  Future<Project?> getByIdInLaunchpad(int launchpadId, String idInLaunchpad) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = '''
      SELECT * FROM Project
      WHERE
        launchpadId = ? AND
        idInLaunchpad = ?
    ''';
    final results = await connection.query(sql, [
      launchpadId,
      idInLaunchpad,
    ]);

    return _getFromRowIfAny(results);
  }

  Future<Iterable<Project>> getByTokenAddress(EthereumAddress address) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = 'SELECT * FROM Project WHERE tokenAddress = ? ORDER BY id';
    final results = await connection.query(sql, [address.hex]);

    return _getAllFromRows(results);
  }

  Future<Iterable<Project>> getByStatus(ProjectStatus status) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = '''
      SELECT * FROM Project
      WHERE
        status = ?
    ''';
    final results = await connection.query(sql, [
      status.name,
    ]);

    return _getAllFromRows(results);
  }

  Future<Iterable<Project>> getUnlockedByStatus(ProjectStatus status) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = '''
      SELECT * FROM Project
      WHERE
        status = ? AND
        lockPid IS NULL
    ''';
    final results = await connection.query(sql, [
      status.name,
    ]);

    return _getAllFromRows(results);
  }

  Project? _getFromRowIfAny(Results results) {
    for (final row in results) {
      return _getFromRow(row);
    }
    return null;
  }

  Iterable<Project> _getAllFromRows(Results results) {
    return results.map((row) => _getFromRow(row));
  }

  Project _getFromRow(ResultRow row) {
    final fields = row.fields;

    return Project(
      id: fields['id'] as int,
      launchpadId: fields['launchpadId'] as int,
      chain: getChainById(fields['chainId']),
      idInLaunchpad: fields['idInLaunchpad'] as String,
      title: fields['title'] as String,
      symbol: fields['symbol'] as String,
      dateTimeInserted: dateTimeFromSecondsSinceEpoch(fields['dateTimeInserted']),
      dateTimeUpdated: dateTimeFromSecondsSinceEpoch(fields['dateTimeUpdated']),
      tokenAddress: ethereumAddressFromHexOrNull(fields['tokenAddress']),
      dateTimePoolCreationEstimate: dateTimeOrNullFromSecondsSinceEpoch(fields['dateTimePoolCreationEstimate']),
      status: ProjectStatus.values.byName(fields['status']),
      firstLiquidityBlock: fields['firstLiquidityBlock'] as int?,
      lockPid: fields['lockPid'],
      presaleUsdPrice: fields['presaleUsdPrice'],
      initialDexUsdPrice: fields['initialDexUsdPrice'],
      xAfterStopLoss: fields['xAfterStopLoss'],
      tradable: fields['tradable'] > 0,
    );
  }
}
