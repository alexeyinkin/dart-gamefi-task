import 'package:rxdart/rxdart.dart';

import '../db/project.dart';
import '../launchpads/abstract.dart';
import '../launchpads/bscpad.dart';
import '../launchpads/gamefi.dart';

class ProjectsBloc {
  final _projectDbService = ProjectDbService();

  final _eventsController = BehaviorSubject<ProjectsBlocEvent>();
  Stream<ProjectsBlocEvent> get events => _eventsController.stream;

  Future<void> grabOnce() async {
    final launchpads = _getLaunchpads();

    for (final launchpad in launchpads) {
      print('Projects for launchpad ${launchpad.id} ${launchpad.title}');
      final projects = await launchpad.getProjects();

      print(projects);
    }
  }

  List<AbstractLaunchpad> _getLaunchpads() {
    return [
      BSCPadLaunchpad(),
      GameFiLaunchpad(),
    ];
  }
}

abstract class ProjectsBlocEvent {}
