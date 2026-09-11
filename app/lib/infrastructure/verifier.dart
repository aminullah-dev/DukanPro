import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Verifies a secret (password or PIN) against a stored verifier — used for
/// offline unlock. No secret leaves the device; only a salted argon2id hash is
/// stored. Stored format: `base64(salt):base64(hash)`.
abstract interface class PasswordVerifier {
  Future<String> derive(String secret);
  Future<bool> verify(String secret, String stored);
}

class Argon2Verifier implements PasswordVerifier {
  Argon2Verifier({
    this.memory = 8192, // 8 MiB blocks
    this.iterations = 2,
    this.parallelism = 1,
    this.hashLength = 32,
  });

  final int memory;
  final int iterations;
  final int parallelism;
  final int hashLength;

  Argon2id get _algo => Argon2id(
        memory: memory,
        parallelism: parallelism,
        iterations: iterations,
        hashLength: hashLength,
      );

  @override
  Future<String> derive(String secret) async {
    final salt = _randomBytes(16);
    final hash = await _hash(secret, salt);
    return '${base64Encode(salt)}:${base64Encode(hash)}';
  }

  @override
  Future<bool> verify(String secret, String stored) async {
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    final salt = base64Decode(parts[0]);
    final expected = base64Decode(parts[1]);
    final actual = await _hash(secret, salt);
    return _constTimeEquals(actual, expected);
  }

  Future<List<int>> _hash(String secret, List<int> salt) async {
    final key = await _algo.deriveKey(
      secretKey: SecretKey(utf8.encode(secret)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  List<int> _randomBytes(int n) {
    final r = Random.secure();
    return List<int>.generate(n, (_) => r.nextInt(256));
  }

  bool _constTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
