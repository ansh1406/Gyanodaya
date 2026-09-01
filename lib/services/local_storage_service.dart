import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _userKeyPrefix = 'user:';
  static const _loginStateKey = 'current_user';

  Future<void> saveUserRecord(String phone, Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_userKeyPrefix$phone', jsonEncode(record));
  }

  Future<Map<String, dynamic>?> getUserRecord(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_userKeyPrefix$phone');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> deleteUser(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_userKeyPrefix$phone');
  }

  Future<void> saveLoginState(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginStateKey, phone);
  }

  Future<String?> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loginStateKey);
  }

  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginStateKey);
  }
}
