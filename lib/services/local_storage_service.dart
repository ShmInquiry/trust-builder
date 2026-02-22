import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyUsername = 'user_username';
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';
  static const _keyIsLoggedIn = 'user_logged_in';

  static Future<bool> saveUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    return true;
  }

  static Future<bool> validateLogin({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_keyEmail);
    final storedPassword = prefs.getString(_keyPassword);

    if (storedEmail == null || storedPassword == null) {
      return false;
    }

    return storedEmail == email && storedPassword == password;
  }

  static Future<bool> hasRegisteredUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) != null;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
