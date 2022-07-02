import 'package:model_interfaces/model_interfaces.dart';

class Metric implements WithId<int> {
  final int id;
  final String title;

  Metric({
    required this.id,
    required this.title,
  });
}
