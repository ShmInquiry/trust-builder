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

    if (path == '/') path = '/index.html';

    final file = File('build/web$path');
    if (await file.exists()) {
      final ext = path.split('.').last;
      final contentType = _contentType(ext);
      request.response.headers.set('Content-Type', contentType);
      request.response.headers.set('Cache-Control', 'no-cache');
      await request.response.addStream(file.openRead());
    } else {
      final indexFile = File('build/web/index.html');
      request.response.headers.set('Content-Type', 'text/html');
      request.response.headers.set('Cache-Control', 'no-cache');
      await request.response.addStream(indexFile.openRead());
    }
    await request.response.close();
  }
}

Future<void> _proxyToBackend(HttpRequest request) async {
  try {
    final client = HttpClient();
    final backendUri = Uri.parse('http://127.0.0.1:3001${request.uri.toString()}');
    final proxyRequest = await client.openUrl(request.method, backendUri);

    request.headers.forEach((name, values) {
      if (name.toLowerCase() != 'host') {
        for (final v in values) {
          proxyRequest.headers.add(name, v);
        }
      }
    });

    final requestBody = await request.fold<List<int>>([], (prev, chunk) => prev..addAll(chunk));
    if (requestBody.isNotEmpty) {
      proxyRequest.add(requestBody);
    }

    final proxyResponse = await proxyRequest.close();

    request.response.statusCode = proxyResponse.statusCode;
    proxyResponse.headers.forEach((name, values) {
      for (final v in values) {
        request.response.headers.add(name, v);
      }
    });

    await request.response.addStream(proxyResponse);
    await request.response.close();
    client.close();
  } catch (e) {
    request.response.statusCode = 502;
    request.response.headers.set('Content-Type', 'application/json');
    request.response.write(json.encode({
      'success': false,
      'error': 'Backend unavailable',
    }));
    await request.response.close();
  }
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
