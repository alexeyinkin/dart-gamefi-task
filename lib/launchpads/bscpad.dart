import 'dart:convert';

import 'package:http/http.dart' as http;

import 'abstract.dart';
import '../models/chain_enum.dart';
import '../models/launchpad_enum.dart';
import '../utils/utils.dart';

class BSCPadLaunchpad extends AbstractLaunchpad {
  static final _projectsUrl = Uri.parse('https://bscpad.com/api/projects');

  @override
  final id = LaunchpadIds.bscpad;

  @override
  final title = 'BSCPad';

  @override
  Future<List<GrabbedProject>> getProjects() async {
    final result = <GrabbedProject>[];
    final response = await http.get(_projectsUrl);

    final statusCode = response.statusCode;
    if (statusCode != 200) {
      throw Exception('HTTP Status $statusCode trying to get $_projectsUrl');
    }

    final list = jsonDecode(response.body) as List;

    for (final map in list) {
      result.add(_parseProject(map));
    }

    return result;
  }

  GrabbedProject _parseProject(Map map) {
    final tokenAddress = (map['projectTokenContract'] ?? '').trim();

    return GrabbedProject(
      launchpadId:                  id,
      chain:                        ChainEnum.bsc,
      idInLaunchpad:                map['id'].toString(),
      title:                        map['name'],
      symbol:                       map['projectTokenSymbol'],
      tokenAddress:                 tokenAddress == '' ? null : ethereumAddressFromHexOrNull(tokenAddress),
      dateTimePoolCreationEstimate: null,
    );
  }
}
