import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import '../config/reader.dart';

class TelegramProvider {
  static TeleDart? _teledart;
  static TelegramSender? _sender;

  static Future<TelegramSender> getInstance() async {
    if (_sender == null) {
      final config = ConfigReader.read();
      final telegramConfig = config.telegram;
      if (telegramConfig == null) {
        throw Exception('No Telegram configuration.');
      }

      final username = (await Telegram(telegramConfig.botKey).getMe()).username;
      _teledart = TeleDart(telegramConfig.botKey, Event(username ?? ''));
      _sender = TelegramSender(teledart: _teledart!, recipientIds: telegramConfig.recipientIds);
    }

    return _sender!;
  }
}

class TelegramSender {
  final TeleDart teledart;
  final List<int> recipientIds;

  TelegramSender({
    required this.teledart,
    required this.recipientIds,
  });

  Future<void> sendString(String text) async {
    for (final chatId in recipientIds) {
      await teledart.sendMessage(chatId, text);
    }
  }
}
