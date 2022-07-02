import 'dart:io';

import 'abstract.dart';
import '../blocs/projects.dart';
import '../utils/telegram.dart';

class ProjectsCommand extends AbstractCommand {
  static const command = 'projects';

  Future<void> run() async {
    final bloc = ProjectsBloc();
    bloc.events.listen(_onProjectsBlocEvent);

    await bloc.grabOnce();
  }

  void _onProjectsBlocEvent(ProjectsBlocEvent event) async {
    final text = '$event';

    stdout.write('$text\n');

    final telegramSender = await TelegramProvider.getInstance();
    telegramSender.sendString(text);
  }
}
