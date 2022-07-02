import 'dart:io';

import 'package:yaml/yaml.dart';

import 'config.dart';

class ConfigReader {
  static const fileName = 'config.yaml';

  static Config read() {
    final file = File(fileName);
    final content = file.readAsStringSync();
    final map = loadYaml(content) as YamlMap;

    return Config.fromMap(map);
  }
}
