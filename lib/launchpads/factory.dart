import 'abstract.dart';
import 'gamefi.dart';
import '../models/launchpad_enum.dart';

// Unused.
class LaunchpadFactory {
  AbstractLaunchpad createById(int id) {
    switch (id) {
      case LaunchpadIds.gamefi: return GameFiLaunchpad();
    }

    throw Exception('Unknown launchpad ID: $id');
  }
}
