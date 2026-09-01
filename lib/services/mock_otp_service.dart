import 'dart:math';
import 'dart:async';

import 'otp_service.dart';

class MockOtpService implements OtpService {
  static final Map<String, String> _store = {};

  static final MockOtpService instance = MockOtpService._internal();
  MockOtpService._internal();

  String _generateCode() {
    final rnd = Random.secure();
    final code = List<int>.generate(6, (_) => rnd.nextInt(10));
    return code.join();
  }

  @override
  Future<String> requestOtp(String phone) async {
    final code = _generateCode();
    _store[phone] = code;
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return code;
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final expected = _store[phone];
    if (expected == null) return false;
    final ok = expected == otp;
    if (ok) _store.remove(phone);
    return ok;
  }
}
