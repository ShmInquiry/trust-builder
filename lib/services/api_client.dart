import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? token;

  String get _baseUrl {
    if (kIsWeb) {
      return '';
    }
    return 'http://localhost:3001';
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> request(
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
}
