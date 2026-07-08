import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuth {
  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'admin123';
  static const String _usernameKey = 'admin_username';
  static const String _passwordKey = 'admin_password';
  static const String _hashPrefix = 'sha256:';

  static String _hashPassword(String password) {
    final digest = sha256.convert(utf8.encode(password));
    return '$_hashPrefix$digest';
  }

  static bool _isHashed(String value) => value.startsWith(_hashPrefix);

  /// Check if custom credentials are set.
  static Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_usernameKey) && prefs.containsKey(_passwordKey);
  }

  /// Set admin credentials (password stored as SHA-256 hash).
  static Future<bool> setCredentials(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username.trim());
      await prefs.setString(_passwordKey, _hashPassword(password));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? defaultUsername;
  }

  static Future<bool> validateCredentials(
    String username,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString(_usernameKey) ?? defaultUsername;
    final storedPassword = prefs.getString(_passwordKey);

    if (username.trim() != storedUsername) return false;

    if (storedPassword == null) {
      return password == defaultPassword;
    }

    if (_isHashed(storedPassword)) {
      return _hashPassword(password) == storedPassword;
    }

    // Legacy plain-text password — validate then migrate to hash.
    if (password == storedPassword) {
      await prefs.setString(_passwordKey, _hashPassword(password));
      return true;
    }
    return false;
  }

  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_passwordKey);
  }
}
