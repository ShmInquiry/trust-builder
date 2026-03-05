import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final server = await HttpServer.bind('0.0.0.0', 5000);
  print('Serving Flutter web app on http://0.0.0.0:5000');

  await for (final request in server) {
    var path = request.uri.path;

    if (path.startsWith('/api/') || path == '/health') {
      await _proxyToBackend(request);
      continue;
    }

    if (path == '/flutter_service_worker.js') {
      request.response.headers.set('Content-Type', 'application/javascript');
      request.response.headers.set('Cache-Control', 'no-cache');
      request.response.write('''
self.addEventListener('install', function(e) { self.skipWaiting(); });
self.addEventListener('activate', function(e) {
  self.registration.unregister();
});
''');
      await request.response.close();
      continue;
    }

    if (path == '/') path = '/index.html';

    final file = File('build/web$path');
    if (await file.exists()) {
      final ext = path.split('.').last;
      final contentType = _contentType(ext);
      final bytes = await file.readAsBytes();
      
      request.response.headers.set('Content-Type', contentType);
      request.response.headers.set('Cache-Control', 'no-cache, no-store, must-revalidate');
      request.response.headers.set('Cross-Origin-Embedder-Policy', 'credentialless');
      request.response.headers.set('Cross-Origin-Opener-Policy', 'same-origin');
      
      request.response.add(bytes);
    } else {
      final indexFile = File('build/web/index.html');
      final bytes = await indexFile.readAsBytes();
      
      request.response.headers.set('Content-Type', 'text/html');
      request.response.headers.set('Cache-Control', 'no-cache, no-store, must-revalidate');
      request.response.headers.set('Cross-Origin-Embedder-Policy', 'credentialless');
      request.response.headers.set('Cross-Origin-Opener-Policy', 'same-origin');
      
      request.response.add(bytes);
    }
    await request.response.close();
  }
}

Future<void> _proxyToBackend(HttpRequest request) async {
  // MOCK BACKEND FOR SCREENSHOT CAPTURE (Rust bypass)
  request.response.headers.set('Content-Type', 'application/json');
  request.response.headers.set('Access-Control-Allow-Origin', '*');
  
  if (request.method == 'OPTIONS') {
    request.response.statusCode = 200;
    await request.response.close();
    return;
  }

  final path = request.uri.path;
  
  // Fake delay
  await Future.delayed(Duration(milliseconds: 50));

  if (path.contains('/api/auth/login')) {
    final bodyStr = await utf8.decodeStream(request);
    if (bodyStr.contains('wrong@email.com')) {
      request.response.statusCode = 401;
      request.response.write(json.encode({'success': false, 'error': 'Invalid email or password. Please try again.'}));
    } else {
      request.response.statusCode = 200;
      request.response.write(json.encode({
        'success': true, 
        'data': {
          'token': 'mock_token_123',
          'user': {'id': '1', 'username': 'Demo User', 'email': 'demo@trustos.app', 'trust_score': 850}
        }
      }));
    }
  } else if (path.contains('/api/auth/register')) {
    final bodyStr = await utf8.decodeStream(request);
    if (bodyStr.contains('"email":""') || bodyStr.contains('"username":""')) {
      request.response.statusCode = 400;
      request.response.write(json.encode({'success': false, 'error': 'Registration failed. Please try again.'}));
    } else {
      request.response.statusCode = 200;
      request.response.write(json.encode({
        'success': true, 
        'data': {
          'token': 'mock_token_123',
          'user': {'id': '1', 'username': 'Demo User', 'email': 'demo@trustos.app', 'trust_score': 850}
        }
      }));
    }
  } else if (path.contains('/api/trust-score')) {
    request.response.statusCode = 200;
    request.response.write(json.encode({
      'success': true,
      'data': {'score': 850, 'status': 'Healthy', 'last_updated': DateTime.now().toIso8601String()}
    }));
  } else if (path.contains('/api/requests')) {
    request.response.statusCode = 200;
    request.response.write(json.encode({
      'success': true,
      'data': [
        {
          'id': '101', 'title': 'Identity Verification', 'description': 'Alice requires identity endorsement on document XYZ.',
          'status': 'Pending'
        },
        {
          'id': '102', 'title': 'Endorsement', 'description': 'Bob is requesting trust score endorsement.',
          'status': 'Approved'
        }
      ]
    }));
  } else if (path.contains('/api/network')) {
    request.response.statusCode = 200;
    request.response.write(json.encode({
      'success': true,
      'data': [
        {'id': '2', 'peer_name': 'Alice Smith', 'interactions': 12, 'trust_level': 'High', 'position_x': 0.2, 'position_y': 0.3},
        {'id': '3', 'peer_name': 'Bob Jones', 'interactions': 5, 'trust_level': 'Medium', 'position_x': 0.8, 'position_y': 0.7}
      ]
    }));
  } else if (path.contains('/api/alerts')) {
    request.response.statusCode = 200;
    request.response.write(json.encode({
      'success': true,
      'data': [
        {'id': '1', 'title': 'Security Alert', 'message': 'New login from unknown device', 'alert_type': 'system', 'created_at': DateTime.now().subtract(Duration(minutes: 5)).toIso8601String()},
        {'id': '2', 'title': 'Trust Score Update', 'message': 'Trust score increased by 15 points', 'alert_type': 'system', 'created_at': DateTime.now().subtract(Duration(days: 2)).toIso8601String()}
      ]
    }));
  } else {
    request.response.statusCode = 404;
    request.response.write(json.encode({'success': false, 'error': 'Mock route not found'}));
  }
  
  await request.response.close();
}

String _contentType(String ext) {
  switch (ext) {
    case 'html':
      return 'text/html';
    case 'js':
      return 'application/javascript';
    case 'css':
      return 'text/css';
    case 'json':
      return 'application/json';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'ico':
      return 'image/x-icon';
    case 'woff':
      return 'font/woff';
    case 'woff2':
      return 'font/woff2';
    case 'ttf':
      return 'font/ttf';
    case 'otf':
      return 'font/otf';
    default:
      return 'application/octet-stream';
  }
}
