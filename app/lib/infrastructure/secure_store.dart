import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstraction over OS secure storage so the auth logic is testable with a
/// fake (no platform channels in tests).
abstract interface class SecureStore {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class SecureKeys {
  static const refreshToken = 'refresh_token';
  static const accessToken = 'access_token';
  static const passwordVerifier = 'pw_verifier';
  static const pinVerifier = 'pin_verifier';

  /// When the server last confirmed the user (ISO-8601 UTC); caps offline unlock.
  static const validatedAt = 'validated_at';

  /// The user who opted in to biometric unlock on this device.
  static const biometricUser = 'biometric_user';
}

/// Real implementation backed by Keychain / Keystore.
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;

  @override
  Future<void> write(String key, String value) => _s.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _s.read(key: key);

  @override
  Future<void> delete(String key) => _s.delete(key: key);
}
