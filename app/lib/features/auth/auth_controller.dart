import 'package:dukan_data/dukan_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/auth_api.dart';
import '../../infrastructure/secure_store.dart';
import '../../infrastructure/verifier.dart';
import 'auth_state.dart';
import 'providers.dart';

/// Orchestrates authentication: online login (server-authoritative) and
/// offline unlock (local verifier). Transitions [AuthState], which drives the
/// router. See docs/sync-protocol.md for the offline posture.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthUnknown();

  SecureStore get _store => ref.read(secureStoreProvider);
  AuthApi get _api => ref.read(authApiProvider);
  PasswordVerifier get _verifier => ref.read(verifierProvider);
  ProfileStore get _profiles => ProfileStore(ref.read(databaseProvider));

  /// Restore from cache on startup: locked if a cached profile + password
  /// verifier exist, otherwise logged out.
  Future<void> restore() async {
    final profile = await _profiles.current();
    final hasVerifier = await _store.read(SecureKeys.passwordVerifier) != null;
    state = (profile != null && hasVerifier) ? AuthLocked(profile) : const AuthLoggedOut();
  }

  Future<void> loginOnline({required String username, required String password}) async {
    try {
      final res = await _api.login(
        username: username,
        password: password,
        deviceId: ref.read(deviceIdProvider),
      );
      await _persist(res, password);
      final profile = await _profiles.current();
      if (profile != null) state = AuthLoggedIn(profile);
    } on AuthApiException catch (e) {
      state = AuthLoggedOut(error: e.code);
    } on NetworkException {
      state = const AuthLoggedOut(error: 'NETWORK');
    }
  }

  Future<void> bootstrap({
    required String username,
    required String password,
    required String displayName,
    required String shopName,
  }) async {
    try {
      final res = await _api.bootstrap(
        username: username,
        password: password,
        displayName: displayName,
        shopName: shopName,
        deviceId: ref.read(deviceIdProvider),
      );
      await _persist(res, password);
      final profile = await _profiles.current();
      if (profile != null) state = AuthLoggedIn(profile);
    } on AuthApiException catch (e) {
      state = AuthLoggedOut(error: e.code);
    } on NetworkException {
      state = const AuthLoggedOut(error: 'NETWORK');
    }
  }

  Future<void> unlockWithPassword(String password) =>
      _unlock(SecureKeys.passwordVerifier, password);

  Future<void> unlockWithPin(String pin) => _unlock(SecureKeys.pinVerifier, pin);

  Future<void> _unlock(String key, String secret) async {
    final profile = await _profiles.current();
    final stored = await _store.read(key);
    if (profile == null) {
      state = const AuthLoggedOut();
      return;
    }
    if (stored != null && await _verifier.verify(secret, stored)) {
      state = AuthLoggedIn(profile, offline: true);
    } else {
      state = AuthLocked(profile, error: 'WRONG_SECRET');
    }
  }

  /// Optional biometric unlock (after at least one online login).
  Future<bool> unlockWithBiometric() async {
    final profile = await _profiles.current();
    if (profile == null) return false;
    final ok = await ref.read(biometricProvider).authenticate('Unlock DukanPro');
    if (ok) {
      state = AuthLoggedIn(profile, offline: true);
      return true;
    }
    return false;
  }

  /// Set/replace the optional quick-unlock PIN.
  Future<void> setPin(String pin) async =>
      _store.write(SecureKeys.pinVerifier, await _verifier.derive(pin));

  Future<bool> hasPin() async => await _store.read(SecureKeys.pinVerifier) != null;

  Future<void> logout() async {
    final refresh = await _store.read(SecureKeys.refreshToken);
    if (refresh != null) await _api.logout(refresh);
    for (final k in [
      SecureKeys.refreshToken,
      SecureKeys.accessToken,
      SecureKeys.passwordVerifier,
      SecureKeys.pinVerifier,
    ]) {
      await _store.delete(k);
    }
    await _profiles.clear();
    state = const AuthLoggedOut();
  }

  Future<void> _persist(ApiAuthResult res, String password) async {
    await _store.write(SecureKeys.refreshToken, res.tokens.refreshToken);
    await _store.write(SecureKeys.accessToken, res.tokens.accessToken);
    await _store.write(SecureKeys.passwordVerifier, await _verifier.derive(password));
    await _profiles.save(
      userId: res.user.id,
      username: res.user.username,
      displayName: res.user.displayName,
      defaultBranchId: res.user.defaultBranchId,
      branches: res.user.branches
          .map((b) => {
                'branch_id': b.branchId,
                'branch_name': b.branchName,
                'role_name': b.roleName,
              })
          .toList(),
    );
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
