import 'package:dukan_data/dukan_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/auth_api.dart';
import '../../infrastructure/biometric.dart';
import '../../infrastructure/secure_store.dart';
import '../../infrastructure/verifier.dart';

/// Dependency providers. The ones that touch platform channels / the network
/// are overridden in main (real impls) and in tests (fakes).
final secureStoreProvider = Provider<SecureStore>(
    (ref) => throw UnimplementedError('override secureStoreProvider in main'));

final authApiProvider = Provider<AuthApi>(
    (ref) => throw UnimplementedError('override authApiProvider in main'));

final databaseProvider = Provider<AppDatabase>(
    (ref) => throw UnimplementedError('override databaseProvider in main'));

/// Pure-Dart, safe as a default in both app and tests.
final verifierProvider = Provider<PasswordVerifier>((ref) => Argon2Verifier());

final biometricProvider = Provider<BiometricAuth>((ref) => const NoBiometric());

final deviceIdProvider = Provider<String>((ref) => 'unknown-device');

/// The wall clock; tests override it.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
