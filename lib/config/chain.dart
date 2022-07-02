import '../models/chain_enum.dart';

class ChainConfig {
  /// Fastest URL for critical jobs.
  final String mempoolUrl;

  /// Non-crirical live data URL.
  final String liveUrl;
  final String archiveUrl;

  ChainConfig({
    required this.mempoolUrl,
    required this.liveUrl,
    required this.archiveUrl,
  });

  static Map<ChainEnum, ChainConfig> fromMaps(Map maps) {
    return maps
        .map((k, v) => MapEntry<ChainEnum, ChainConfig>(ChainEnum.values.byName(k), ChainConfig.fromMap(v)))
    ;
  }

  factory ChainConfig.fromMap(Map map) {
    return ChainConfig(
      mempoolUrl: map['mempoolUrl'] ?? '',
      liveUrl:    map['liveUrl'] ?? '',
      archiveUrl: map['archiveUrl'] ?? '',
    );
  }
}
