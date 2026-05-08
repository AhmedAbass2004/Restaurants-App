import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthLocalStorageService {
  AuthLocalStorageService._();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyName = 'name';
  static const String _keyEmail = 'email';

  static Future<void> saveLoggedInUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    if (user.id != null) {
      await prefs.setInt(_keyUserId, user.id!);
    }
    await prefs.setString(_keyName, user.name);
    await prefs.setString(_keyEmail, user.email);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    final email = prefs.getString(_keyEmail);
    if (email == null || email.isEmpty) return null;

    return User(
      id: prefs.getInt(_keyUserId),
      name: prefs.getString(_keyName) ?? '',
      email: email,
    );
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
  }
}
