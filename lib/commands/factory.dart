import 'abstract.dart';
import 'projects.dart';

class CommandFactory {
  static AbstractCommand getCommand(List<String> args) {
    switch (args[0]) {
      case ProjectsCommand.command:           return ProjectsCommand();
    }

    throw Exception('Command not found: ${args[0]}');
  }
}
