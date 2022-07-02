import 'package:mysql1/mysql1.dart';

import 'db_connection_provider.dart';
import '../models/metric.dart';

class MetricDbService {
  Future<void> saveValue(int projectId, int metricId, double? value) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = '''
      INSERT INTO `ProjectMetricValue`(
        projectId,
        metricId,
        `value`
      ) VALUES (?, ?, ?)
      ON DUPLICATE KEY UPDATE `value` = ?
    ''';
    await connection.query(sql, [
      projectId,
      metricId,
      value,
      value,
    ]);
  }

  Future<Iterable<Metric>> getAll() async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = 'SELECT * FROM Metric';
    final results = await connection.query(sql, []);

    return _getAllFromRows(results);
  }

  Future<Metric> requireById(int id) async {
    final connection = await DbConnectionProvider.getConnection();
    final sql = 'SELECT * FROM Metric WHERE id = ?';
    final results = await connection.query(sql, [id]);

    return _getFromRow(results.first);
  }

  Metric? _getFromRowIfAny(Results results) {
    for (final row in results) {
      return _getFromRow(row);
    }
    return null;
  }

  Iterable<Metric> _getAllFromRows(Results results) {
    return results.map((row) => _getFromRow(row));
  }

  Metric _getFromRow(ResultRow row) {
    final fields = row.fields;

    return Metric(
      id: fields['id'],
      title: fields['title'],
    );
  }
}
