import '../models/request_model.dart';
import 'api_client.dart';

class RequestService {
  static final RequestService _instance = RequestService._internal();
  factory RequestService() => _instance;
  RequestService._internal();

  Future<List<RequestModel>> getRequests() async {
    final result = await ApiClient().request('GET', '/api/requests');
    if (result['success'] == true && result['data'] != null) {
      final list = result['data'] as List;
      return list.map((item) => RequestModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<RequestModel?> getRequest(String id) async {
    final result = await ApiClient().request('GET', '/api/requests/$id');
    if (result['success'] == true && result['data'] != null) {
      return RequestModel.fromJson(result['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<({bool success, String? error})> createRequest({
    required String title,
    required String description,
    String? status,
    List<String>? peers,
    String? documentId,
  }) async {
    final result = await ApiClient().request('POST', '/api/requests', body: {
      'title': title,
      'description': description,
      if (status != null) 'status': status,
      if (peers != null && peers.isNotEmpty) 'peers': peers,
      if (documentId != null) 'document_id': documentId,
    });

    if (result['success'] == true) {
      return (success: true, error: null);
    }
    return (success: false, error: result['error'] as String? ?? 'Failed to create request');
  }

  Future<bool> updateRequestStatus(String id, String status) async {
    final result = await ApiClient().request('PUT', '/api/requests/$id/status', body: {
      'status': status,
    });
    return result['success'] == true;
  }
}
