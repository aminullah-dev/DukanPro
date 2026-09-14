import 'package:local_auth/local_auth.dart';

/// Optional biometric / device-credential unlock, behind an interface so tests
/// use a no-op and never touch the plugin.
abstract interface class BiometricAuth {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

class NoBiometric implements BiometricAuth {
  const NoBiometric();
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<bool> authenticate(String reason) async => false;
}

class LocalAuthBiometric implements BiometricAuth {
  LocalAuthBiometric([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();
  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      // Biometrics only: a shared till's device PIN proves nothing about which
      // app user is standing there.
      return await _auth.authenticate(localizedReason: reason, biometricOnly: true);
    } on Object {
      return false;
    }
  }
}
