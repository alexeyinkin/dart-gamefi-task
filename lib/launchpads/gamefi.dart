import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import 'abstract.dart';
import '../models/chain_enum.dart';
import '../models/launchpad_enum.dart';
import '../utils/utils.dart';

class GameFiLaunchpad extends AbstractLaunchpad {
  static final _urls = [
    'https://hub.gamefi.org/api/v1/pools?limit=10&title=&token_type=erc20',
  ];

  static const _bsc = 'bsc';
  static const _eth = 'eth';
  static const _polygon = 'polygon';

  static const _nullAddresses = {
    '',
    '0xe23c8837560360ff0d49ed005c5e3ad747f50b3d',
  };

  @override
  final id = LaunchpadIds.gamefi;

  @override
  final title = 'GameFi';

  @override
  Future<List<GrabbedProject>> getProjects() async {
    final result = <GrabbedProject>[];

    for (final url in _urls) {
      int page = 1;
      int lastPage = 1;
      while (page <= lastPage) {
        final response = await http.get(Uri.parse(url + '&page=$page'));

        final statusCode = response.statusCode;
        if (statusCode != 200) {
          throw Exception('HTTP Status $statusCode trying to get $url');
        }

        final responseMap = (jsonDecode(response.body) as Map)['data'];
        lastPage = toIntIfNot(responseMap['lastPage']);

        for (final map in responseMap['data']) {
          result.add(_parseProject(map));
        }

        page++;
      }
    }
    return result;
  }

  GrabbedProject _parseProject(Map map) {
    return GrabbedProject(
      launchpadId:                  id,
      chain:                        _getChain(map['network_available']),
      idInLaunchpad:                map['id'].toString(),
      title:                        map['title'],
      symbol:                       map['symbol'],
      tokenAddress:                 _getTokenAddress(map),
      dateTimePoolCreationEstimate: null,
    );
  }

  EthereumAddress? _getTokenAddress(Map map) {
    final inputAddress = (map['token'] as String? ?? '').trim();

    if (_nullAddresses.contains(inputAddress.toLowerCase())) return null;
    return EthereumAddress.fromHex(inputAddress);
  }

  ChainEnum _getChain(String chain) {
    switch (chain) {
      case _bsc: return ChainEnum.bsc;
      case _eth: return ChainEnum.eth;
      case _polygon: return ChainEnum.polygon;
    }
    throw Exception('Unknown chain: $chain');
  }
}
