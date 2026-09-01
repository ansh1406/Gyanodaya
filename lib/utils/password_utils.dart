import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

String _base64(Uint8List bytes) => base64.encode(bytes);

Uint8List _hmac(Uint8List key, Uint8List data) {
  final hmac = Hmac(sha256, key);
  return Uint8List.fromList(hmac.convert(data).bytes);
}

Uint8List _int32BigEndian(int i) {
  final bytes = ByteData(4);
  bytes.setUint32(0, i, Endian.big);
  return bytes.buffer.asUint8List();
}

String generateSalt([int length = 16]) {
  final rnd = Random.secure();
  final bytes = Uint8List(length);
  for (var i = 0; i < length; i++) {
    bytes[i] = rnd.nextInt(256);
  }
  return _base64(bytes);
}

/// PBKDF2-HMAC-SHA256 implementation returning base64-encoded derived key.
String pbkdf2(String password, String saltBase64, int iterations, int dkLen) {
  final passwordBytes = utf8.encode(password);
  final salt = base64.decode(saltBase64);

  final blocks = (dkLen + 31) ~/ 32;
  final out = <int>[];

  for (var blockIndex = 1; blockIndex <= blocks; blockIndex++) {
    var u = _hmac(Uint8List.fromList(passwordBytes), Uint8List.fromList(salt + _int32BigEndian(blockIndex)));
    final t = List<int>.from(u);
    for (var i = 1; i < iterations; i++) {
      u = _hmac(Uint8List.fromList(passwordBytes), u);
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    out.addAll(t);
  }

  final derived = Uint8List.fromList(out.sublist(0, dkLen));
  return _base64(derived);
}

String hashPassword(String password, String saltBase64, {int iterations = 100000, int dkLen = 32}) {
  return pbkdf2(password, saltBase64, iterations, dkLen);
}

bool verifyPassword(String password, String saltBase64, String hashBase64, {int iterations = 100000, int dkLen = 32}) {
  final candidate = hashPassword(password, saltBase64, iterations: iterations, dkLen: dkLen);
  return constantTimeEquals(candidate, hashBase64);
}

bool constantTimeEquals(String a, String b) {
  final aBytes = utf8.encode(a);
  final bBytes = utf8.encode(b);
  if (aBytes.length != bBytes.length) return false;
  var result = 0;
  for (var i = 0; i < aBytes.length; i++) {
    result |= aBytes[i] ^ bBytes[i];
  }
  return result == 0;
}
