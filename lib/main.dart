import 'commands/factory.dart';
import 'logging/logging.dart';

void main(List<String> args) async {
  await AppLogger.instance.init(args);

  final command = CommandFactory.getCommand(args);
  await command.runBase();
}
