import 'dart:async';
import 'dart:developer' as developer;

import 'package:dukan_data/dukan_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/auth_api.dart';
import '../../infrastructure/http.dart';
import '../../infrastructure/secure_store.dart';
import '../../infrastructure/verifier.dart';
import 'auth_state.dart';
import 'providers.dart';

/// Orchestrates authentication: online login (server-authoritative), offline
/// unlock (local verifier), and revalidation against the server whenever it is
/// reachable. Transitions [AuthState], which drives the router. See
/// docs/domain/identity-access.md for the session rules.
class AuthController extends Notifier<AuthState> {
  /// How long a device may keep unlocking offline since the server last
  /// confirmed the user: long enough for a shop without internet, short enough
  /// that a disabled employee's cached password stops working.
  static const maxOfflineUnlock = Duration(days: 30);

  /// How far the clock may step back (a time sync) before it counts as set back.
  static const clockSkew = Duration(minutes: 5);

  @override
  AuthState build() => const AuthUnknown();

  SecureStore get _store => ref.read(secureStoreProvider);
  AuthApi get _api => ref.read(authApiProvider);
  PasswordVerifier get _verifier => ref.read(verifierProvider);
  DateTime _now() => ref.read(clockProvider)().toUtc();
  ProfileStore get _profiles => ProfileStore(ref.read(databaseProvider));

  /// Dismiss a lingering sign-in error (e.g. when switching to setup mode).
  void clearError() {
    final s = state;
    if (s is AuthLoggedOut && s.error != null) state = AuthLoggedOut(returnTo: s.returnTo);
  }

  /// Restore from cache on startup: locked if a cached profile + password
  /// verifier exist, otherwise logged out.
  Future<void> restore() async {
    try {
      final profile = await _profiles.current();
      final hasVerifier = await _store.read(SecureKeys.passwordVerifier) != null;
      state = (profile != null && hasVerifier) ? AuthLocked(profile) : const AuthLoggedOut();
    } catch (e, st) {
      // Secure storage or the database could not be read (a locked keychain, a
      // failed migration): say so on the sign-in screen instead of spinning.
      developer.log('restore failed', name: 'auth', error: e, stackTrace: st);
      state = const AuthLoggedOut(error: 'STORAGE_UNAVAILABLE');
    }
  }

  Future<void> loginOnline({required String username, required String password}) async {
    final returnTo = _returnTo;
    try {
      final res = await _api.login(
        username: username,
        password: password,
        deviceId: ref.read(deviceIdProvider),
      );
      final profile = await _persist(res, password);
      if (profile != null) state = AuthLoggedIn(profile);
    } on AuthApiException catch (e) {
      state = AuthLoggedOut(error: e.code, returnTo: returnTo);
    } on NetworkException {
      state = AuthLoggedOut(error: 'NETWORK', returnTo: returnTo);
    }
  }

  Future<void> bootstrap({
    required String username,
    required String password,
    required String displayName,
    required String shopName,
    required String setupCode,
  }) async {
    try {
      final res = await _api.bootstrap(
        username: username,
        password: password,
        displayName: displayName,
        shopName: shopName,
        deviceId: ref.read(deviceIdProvider),
        setupToken: setupCode,
      );
      final profile = await _persist(res, password);
      if (profile != null) state = AuthLoggedIn(profile);
    } on AuthApiException catch (e) {
      state = AuthLoggedOut(error: e.code);
    } on NetworkException {
      state = const AuthLoggedOut(error: 'NETWORK');
    }
  }

  CachedProfileRow? get _returnTo {
    final s = state;
    return s is AuthLoggedOut ? s.returnTo : null;
  }

  Future<void> unlockWithPassword(String password) =>
      _unlock(SecureKeys.passwordVerifier, password);

  Future<void> unlockWithPin(String pin) => _unlock(SecureKeys.pinVerifier, pin);

  Future<void> _unlock(String key, String secret) async {
    final profile = await _profiles.current();
    if (profile == null) {
      state = const AuthLoggedOut();
      return;
    }
    final stored = await _store.read(key);
    if (stored == null || !await _verifier.verify(secret, stored)) {
      state = AuthLocked(profile, error: 'WRONG_SECRET');
      return;
    }
    state = await _offlineAllowed()
        ? AuthLoggedIn(profile, offline: true)
        : const AuthLoggedOut(error: 'OFFLINE_EXPIRED');
  }

  /// Whether the server confirmed this user recently enough to unlock offline.
  Future<bool> _offlineAllowed() async {
    final raw = await _store.read(SecureKeys.validatedAt);
    if (raw == null) {
      // A device from before this rule starts its offline window now.
      await _markValidated();
      return true;
    }
    final at = DateTime.tryParse(raw);
    if (at == null) return false;
    final now = _now();
    final seen = DateTime.tryParse(await _store.read(SecureKeys.lastSeenAt) ?? '') ?? at;
    // A clock set back behind a time this device already saw would keep the
    // window open for ever: that needs the server again.
    if (now.isBefore(seen.subtract(clockSkew))) return false;
    if (now.difference(at) > maxOfflineUnlock) return false;
    if (now.isAfter(seen)) await _store.write(SecureKeys.lastSeenAt, now.toIso8601String());
    return true;
  }

  Future<void> _markValidated() async {
    final now = _now().toIso8601String();
    await _store.write(SecureKeys.validatedAt, now);
    await _store.write(SecureKeys.lastSeenAt, now);
  }

  /// Biometric unlock, only for the user who opted in on this device: never on
  /// by default, so another fingerprint enrolled on a shared till opens nothing.
  Future<bool> unlockWithBiometric() async {
    final profile = await _profiles.current();
    if (profile == null || !await biometricEnabled()) return false;
    if (!await ref.read(biometricProvider).authenticate('Unlock DukanPro')) return false;
    if (!await _offlineAllowed()) {
      state = const AuthLoggedOut(error: 'OFFLINE_EXPIRED');
      return false;
    }
    state = AuthLoggedIn(profile, offline: true);
    return true;
  }

  Future<bool> biometricEnabled() async {
    final profile = await _profiles.current();
    return profile != null && await _store.read(SecureKeys.biometricUser) == profile.userId;
  }

  /// Opt in to biometric unlock, confirmed with the app password.
  Future<bool> enableBiometric(String password) async {
    final profile = await _profiles.current();
    final stored = await _store.read(SecureKeys.passwordVerifier);
    if (profile == null || stored == null || !await _verifier.verify(password, stored)) {
      return false;
    }
    await _store.write(SecureKeys.biometricUser, profile.userId);
    return true;
  }

  Future<void> disableBiometric() => _store.delete(SecureKeys.biometricUser);

  /// Set/replace the optional quick-unlock PIN.
  Future<void> setPin(String pin) async =>
      _store.write(SecureKeys.pinVerifier, await _verifier.derive(pin));

  Future<bool> hasPin() async => await _store.read(SecureKeys.pinVerifier) != null;

  /// Lock without signing out: the credentials stay, so offline unlock works.
  void lock() {
    final s = state;
    if (s is AuthLoggedIn) state = AuthLocked(s.profile);
  }

  /// From the lock screen, sign in as someone else. The cached session stays
  /// until that sign-in succeeds, and [restore] returns to it.
  void useAnotherAccount() {
    final s = state;
    if (s is AuthLocked) state = AuthLoggedOut(returnTo: s.profile);
  }

  /// Confirm the signed-in user with the server when it is reachable: refresh
  /// the cached roles, or sign out when the account or session has ended.
  /// Offline, nothing changes. After a password unlock, pass that [password]:
  /// a session that simply ended (expired or revoked) then renews by signing in
  /// again with it.
  Future<void> revalidate({String? password}) async {
    if (state is! AuthLoggedIn) return;
    try {
      final profile = await _me();
      await _saveProfile(profile);
      await _markValidated();
      final current = await _profiles.current();
      if (current != null && state is AuthLoggedIn) state = AuthLoggedIn(current);
    } on AuthApiException catch (e) {
      if (!sessionEndedCodes.contains(e.code)) return;
      final failed = password == null || e.code == 'USER_DISABLED'
          ? e.code
          : await _signInAgain(password, ended: e.code);
      if (failed != null) await sessionEnded(failed);
    } on NetworkException {
      // Offline: keep working from the cache.
    }
  }

  /// Sign in online with the password that just unlocked the device. Null on
  /// success, else the code to end the session with.
  Future<String?> _signInAgain(String password, {required String ended}) async {
    final profile = await _profiles.current();
    if (profile == null) return ended;
    try {
      final res = await _api.login(
        username: profile.username,
        password: password,
        deviceId: ref.read(deviceIdProvider),
      );
      final saved = await _persist(res, password);
      if (saved != null && state is AuthLoggedIn) state = AuthLoggedIn(saved);
      return saved == null ? ended : null;
    } on AuthApiException catch (e) {
      return e.code == 'USER_DISABLED' ? e.code : ended;
    } on NetworkException {
      return ended;
    }
  }

  /// `/auth/me`, renewing the access token once when it has expired.
  Future<ApiProfile> _me() async {
    final access = await _store.read(SecureKeys.accessToken);
    try {
      return await _api.me(access ?? '');
    } on AuthApiException catch (e) {
      if (e.code != 'TOKEN_EXPIRED' && e.code != 'AUTH_REQUIRED') rethrow;
      return _api.me(await ref.read(tokenRefresherProvider).renew(access));
    }
  }

  /// The server no longer accepts this session or account: wipe the saved
  /// sign-in and ask for an online sign-in. Safe to call more than once.
  Future<void> sessionEnded(String code) async {
    final s = state;
    if (s is AuthLoggedOut || s is AuthUnknown) return;
    await _forget();
    state = AuthLoggedOut(error: code);
  }

  /// Sign out: wipe the device first, then tell the server best-effort, so a
  /// bad connection never keeps the app signed in.
  Future<void> logout() async {
    final refresh = await _store.read(SecureKeys.refreshToken);
    await _forget();
    state = const AuthLoggedOut();
    if (refresh != null) unawaited(_api.logout(refresh));
  }

  /// Remove every trace of the signed-in user from this device. The outbox
  /// stays: it syncs when its recorder signs in again.
  Future<void> _forget() async {
    for (final k in [
      SecureKeys.refreshToken,
      SecureKeys.accessToken,
      SecureKeys.passwordVerifier,
      SecureKeys.pinVerifier,
      SecureKeys.biometricUser,
      SecureKeys.validatedAt,
      SecureKeys.lastSeenAt,
    ]) {
      await _store.delete(k);
    }
    await _profiles.clear();
  }

  Future<CachedProfileRow?> _persist(ApiAuthResult res, String password) async {
    final previous = await _profiles.current();
    if (previous != null && previous.userId != res.user.id) {
      // The quick unlocks belonged to the previous user.
      await _store.delete(SecureKeys.pinVerifier);
      await _store.delete(SecureKeys.biometricUser);
    }
    await _store.write(SecureKeys.refreshToken, res.tokens.refreshToken);
    await _store.write(SecureKeys.accessToken, res.tokens.accessToken);
    await _store.write(SecureKeys.passwordVerifier, await _verifier.derive(password));
    await _markValidated();
    await _saveProfile(res.user);
    return _profiles.current();
  }

  /// The cached profile is always the server's answer for the one signed-in user.
  Future<void> _saveProfile(ApiProfile p) => _profiles.replace(
        userId: p.id,
        username: p.username,
        displayName: p.displayName,
        defaultBranchId: p.defaultBranchId,
        branches: [
          for (final b in p.branches)
            {'branch_id': b.branchId, 'branch_name': b.branchName, 'role_name': b.roleName},
        ],
      );
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
