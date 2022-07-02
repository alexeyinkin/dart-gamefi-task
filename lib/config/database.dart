class DatabaseConfig {
  final String host;
  final int port;
  final String username;
  final String password;
  final String database;

  DatabaseConfig({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.database,
  });

  static DatabaseConfig? fromMap(Map? map) {
    if (map == null) return null;

    return DatabaseConfig(
      host: map['host'],
      port: map['port'],
      username: map['username'],
      password: map['password'],
      database: map['database'],
    );
  }
}
