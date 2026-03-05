import 'local_storage_service.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? userId;
  String? username;
  String? email;

  bool get isLoggedIn => ApiClient().token != null;

  Future<bool> restoreSession() async {
    final session = await LocalStorageService.getSavedSession();
    if (session == null) return false;
    ApiClient().token = session['token'];
    userId = session['userId'];
    username = session['username'];
    email = session['email'];
    return true;
  }

  Future<({bool success, String? error})> login(String emailInput, String password) async {
    final result = await ApiClient().request('POST', '/api/auth/login', body: {
      'email': emailInput,
      'password': password,
    });

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      ApiClient().token = data['token'];
      userId = data['user']['id'];
      username = data['user']['username'];
      email = data['user']['email'];
      await LocalStorageService.saveSession(
        token: ApiClient().token!,
        userId: userId!,
        username: username ?? '',
        email: email ?? '',
      );
      return (success: true, error: null);
    }

    return (success: false, error: result['error'] as String? ?? 'Login failed');
  }

  Future<({bool success, String? error})> register(String usernameInput, String emailInput, String password) async {
    final result = await ApiClient().request('POST', '/api/auth/register', body: {
      'username': usernameInput,
      'email': emailInput,
      'password': password,
    });

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      ApiClient().token = data['token'];
      userId = data['user']['id'];
      username = data['user']['username'];
      email = data['user']['email'];
      await LocalStorageService.saveSession(
        token: ApiClient().token!,
        userId: userId!,
        username: username ?? '',
        email: email ?? '',
      );
      await LocalStorageService.saveUser(
        username: usernameInput,
        email: emailInput,
        password: password,
      );
      return (success: true, error: null);
    }

    return (success: false, error: result['error'] as String? ?? 'Registration failed');
  }

  Future<void> logout() async {
    ApiClient().token = null;
    userId = null;
    username = null;
    email = null;
    await LocalStorageService.logout();
  }
}
