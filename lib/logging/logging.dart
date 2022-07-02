import 'dart:io';

import 'package:logging/logging.dart';

import '../utils/utils.dart';

class AppLogger {
  late final String folder;
  late final File errorLogFile;
  Future? _directoryCreationFuture;

  static final instance = AppLogger();

  Future<void> init(List<String> args) async {
    final now = DateTime.now();
    final path = Directory.current.path;
    final time = now.toStringToSeconds().replaceAll(' ', '_').replaceAll(':', '-');
    folder = '$path/logs/${time}_${args[0]}';

    errorLogFile = File('$folder/errors.log');

    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((LogRecord record) {
      _writeEventLog(record);
    });
  }

  Future<void> _ensureDirectoryExists() async {
    if (_directoryCreationFuture == null) {
      _directoryCreationFuture = Directory(folder).create(recursive: true);
    }

    await _directoryCreationFuture;
  }

  void _writeEventLog(LogRecord record) async {
    await _ensureDirectoryExists();

    final time = record.time.toStringToSeconds();
    errorLogFile.writeAsStringSync(
      '$time ${record.level.name}: ${record.message} ${record.error} ${record.stackTrace}\n',
      mode: FileMode.append,
    );
  }
}
