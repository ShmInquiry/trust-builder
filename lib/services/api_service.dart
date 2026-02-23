import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/request_model.dart';
import '../models/alert_model.dart';
import '../models/network_node_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String? _userId;
  String? _username;
  String? _email;

  String get _baseUrl {
    if (kIsWeb) {
      return '';
    }
    return 'http://localhost:3001';
  }

  String? get token => _token;
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  bool get isLoggedIn => _token != null;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: _headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: _headers, body: body != null ? json.encode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri, headers: _headers, body: body != null ? json.encode(body) : null);
          break;
        default:
          throw Exception('Unsupported method: $method');
      }
    } catch (e) {
      return {'success': false, 'error': 'Unable to connect to server. Please try again.'};
    }

    try {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400 && decoded['success'] != false) {
        return {'success': false, 'error': decoded['error'] ?? 'Request failed (${response.statusCode})'};
      }
      return decoded;
    } catch (_) {
      if (response.statusCode >= 500) {
        return {'success': false, 'error': 'Server error. Please try again later.'};
      }
      if (response.statusCode == 401) {
        return {'success': false, 'error': 'Session expired. Please sign in again.'};
      }
      return {'success': false, 'error': 'Unexpected response from server (${response.statusCode})'};
    }
  }

  Future<({bool success, String? error})> login(String email, String password) async {
    final result = await _request('POST', '/api/auth/login', body: {
      'email': email,
      'password': password,
    });

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      _token = data['token'];
      _userId = data['user']['id'];
      _username = data['user']['username'];
      _email = data['user']['email'];
      return (success: true, error: null);
    }

    return (success: false, error: result['error'] as String? ?? 'Login failed');
  }

  Future<({bool success, String? error})> register(String username, String email, String password) async {
    final result = await _request('POST', '/api/auth/register', body: {
      'username': username,
      'email': email,
      'password': password,
    });

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      _token = data['token'];
      _userId = data['user']['id'];
      _username = data['user']['username'];
      _email = data['user']['email'];
      return (success: true, error: null);
    }

    return (success: false, error: result['error'] as String? ?? 'Registration failed');
  }

  void logout() {
    _token = null;
    _userId = null;
    _username = null;
    _email = null;
  }

  Future<({int score, String status})?> getTrustScore() async {
    final result = await _request('GET', '/api/trust-score');
    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      return (score: data['score'] as int, status: data['status'] as String);
    }
    return null;
  }

  Future<List<RequestModel>> getRequests() async {
    final result = await _request('GET', '/api/requests');
    if (result['success'] == true && result['data'] != null) {
      final list = result['data'] as List;
      return list.map((item) => RequestModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<RequestModel?> getRequest(String id) async {
    final result = await _request('GET', '/api/requests/$id');
    if (result['success'] == true && result['data'] != null) {
      return RequestModel.fromJson(result['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<NetworkNodeModel>> getNetworkPeers() async {
    final result = await _request('GET', '/api/network');
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

  Future<List<AlertModel>> getAlerts({String? filter}) async {
    final queryParams = <String, String>{};
    if (filter != null && filter != 'All') {
      queryParams['filter'] = filter.toLowerCase();
    }
    final result = await _request('GET', '/api/alerts', queryParams: queryParams.isNotEmpty ? queryParams : null);
    if (result['success'] == true && result['data'] != null) {
      final list = result['data'] as List;
      return list.map((item) => AlertModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> markAlertRead(String id) async {
    final result = await _request('PUT', '/api/alerts/$id/read');
    return result['success'] == true;
  }

  Future<({bool success, String? error})> createRequest({
    required String title,
    required String description,
    String? status,
    List<String>? peers,
    String? documentId,
  }) async {
    final result = await _request('POST', '/api/requests', body: {
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
    final result = await _request('PUT', '/api/requests/$id/status', body: {
      'status': status,
    });
    return result['success'] == true;
  }
}
