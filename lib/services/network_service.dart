import '../models/network_node_model.dart';
import 'api_client.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  Future<List<NetworkNodeModel>> getNetworkPeers() async {
    final result = await ApiClient().request('GET', '/api/network');
    if (result['success'] == true && result['data'] != null) {
      final list = result['data'] as List;
      final peers = list.map((item) => NetworkNodeModel.fromJson(item as Map<String, dynamic>)).toList();

      final nodes = <NetworkNodeModel>[
        const NetworkNodeModel(id: 'you', name: 'You', role: '', x: 0.5, y: 0.45),
      ];

      for (int i = 0; i < peers.length; i++) {
        final angle = (i * 2 * 3.14159) / peers.length;
        final radius = 0.3;
        nodes.add(NetworkNodeModel(
          id: peers[i].id,
          name: peers[i].name,
          role: peers[i].role,
          trustLevel: peers[i].trustLevel,
          x: 0.5 + radius * (peers[i].x != 0 ? peers[i].x : _cos(angle)),
          y: 0.45 + radius * (peers[i].y != 0 ? peers[i].y : _sin(angle)),
        ));
      }

      return nodes;
    }
    return [];
  }

  double _cos(double x) {
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _sin(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}
