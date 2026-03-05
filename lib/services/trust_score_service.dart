import 'api_client.dart';

class TrustScoreService {
  static final TrustScoreService _instance = TrustScoreService._internal();
  factory TrustScoreService() => _instance;
  TrustScoreService._internal();

  Future<({int score, String status})?> getTrustScore() async {
    final result = await ApiClient().request('GET', '/api/trust-score');
    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      return (score: data['score'] as int, status: data['status'] as String);
    }
    return null;
  }
}
