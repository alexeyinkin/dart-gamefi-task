class TelegramConfig {
  final String botKey;
  final List<int> recipientIds;

  TelegramConfig({
    required this.botKey,
    required this.recipientIds,
  });

  static TelegramConfig? fromMap(Map? map) {
    if (map == null) return null;

    return TelegramConfig(
      botKey: map['botKey'],
      recipientIds: map['recipientIds'].cast<int>(),
    );
  }
}
