import '../models/alert_model.dart';
import 'api_client.dart';

class AlertsService {
  static final AlertsService _instance = AlertsService._internal();
  factory AlertsService() => _instance;
  AlertsService._internal();

  Future<List<AlertModel>> getAlerts({String? filter}) async {
    final queryParams = <String, String>{};
    if (filter != null && filter != 'All') {
      queryParams['filter'] = filter.toLowerCase();
    }
    final result = await ApiClient().request('GET', '/api/alerts', queryParams: queryParams.isNotEmpty ? queryParams : null);
    if (result['success'] == true && result['data'] != null) {
      final list = result['data'] as List;
      return list.map((item) => AlertModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> markAlertRead(String id) async {
    final result = await ApiClient().request('PUT', '/api/alerts/$id/read');
    return result['success'] == true;
  }
}
