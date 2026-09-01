import 'dart:async';

import '../models/user.dart';
import 'local_storage_service.dart';
import '../utils/password_utils.dart';

class AuthService {
  final LocalStorageService _storage = LocalStorageService();
  static const _iterations = 100000;

  Future<bool> register({required String phone, required String password, String? displayName}) async {
    final existing = await _storage.getUserRecord(phone);
    if (existing != null) return false; // already exists

    final salt = generateSalt();
    final hash = hashPassword(password, salt, iterations: _iterations);

    final record = {
      'phone': phone,
      'displayName': displayName,
      'passwordHash': hash,
      'salt': salt,
      'iterations': _iterations,
    };
    await _storage.saveUserRecord(phone, record);
    await _storage.saveLoginState(phone);
    return true;
  }

  Future<bool> login({required String phone, required String password}) async {
    final record = await _storage.getUserRecord(phone);
    if (record == null) return false;
    final salt = record['salt'] as String;
    final hash = record['passwordHash'] as String;
    final iterations = record['iterations'] as int? ?? _iterations;
    final ok = verifyPassword(password, salt, hash, iterations: iterations);
    if (!ok) return false;
    await _storage.saveLoginState(phone);
    return true;
  }

  Future<void> logout() async {
    await _storage.clearLoginState();
  }

  Future<User?> currentUser() async {
    final phone = await _storage.getLoginState();
    if (phone == null) return null;
    final record = await _storage.getUserRecord(phone);
    if (record == null) return null;
    return User(phone: record['phone'] as String, displayName: record['displayName'] as String?);
  }

  Future<bool> updateProfile({required String phone, String? displayName}) async {
    final record = await _storage.getUserRecord(phone);
    if (record == null) return false;
    record['displayName'] = displayName;
    await _storage.saveUserRecord(phone, record);
    return true;
  }
}
