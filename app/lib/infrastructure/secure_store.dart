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

  /// The latest time this device has seen (ISO-8601 UTC): a clock set back
  /// behind it must not reopen the offline window.
  static const lastSeenAt = 'last_seen_at';

  /// The user who opted in to biometric unlock on this device.
  static const biometricUser = 'biometric_user';

  /// The key the device database is encrypted with (64 hex digits), kept by
  /// [FlutterSecureStore.thisDeviceOnly]. Signing out never removes it.
  static const databaseKey = 'db_key';
}

/// Real implementation backed by Keychain / Keystore.
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();

  /// Items that never leave this device: on iOS they are not restored from a
  /// backup onto another phone, and they can be read from the first unlock
  /// after a restart. For the database key.
  FlutterSecureStore.thisDeviceOnly()
      : _s = const FlutterSecureStorage(
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
        );

  final FlutterSecureStorage _s;

  @override
  Future<void> write(String key, String value) => _s.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _s.read(key: key);

  @override
  Future<void> delete(String key) => _s.delete(key: key);
}
