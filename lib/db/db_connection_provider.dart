import 'package:mysql1/mysql1.dart';

import '../config/reader.dart';
import 'retry_connection.dart';

class DbConnectionProvider {
  static MySqlConnection? _connection;

  static Future<MySqlConnection> getConnection() async {
    if (_connection == null) {
      final config = ConfigReader.read();
      final databaseConfig = config.database;

      if (databaseConfig == null) {
        throw Exception('No DB connection config.');
      }

      final settings = ConnectionSettings(
        host:     databaseConfig.host,
        port:     databaseConfig.port,
        user:     databaseConfig.username,
        password: databaseConfig.password,
        db:       databaseConfig.database,
      );

      _connection = RetryMySqlConnection(await MySqlConnection.connect(settings));
    }

    return _connection!;
  }
}
