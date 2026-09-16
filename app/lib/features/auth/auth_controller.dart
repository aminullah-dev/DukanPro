import 'dart:async';
import 'dart:developer' as developer;

import 'package:dukan_core/dukan_core.dart' show ValidationError, assertPasswordStrong, newId;
import 'package:dukan_data/dukan_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../composition.dart';
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

  /// Answers that end the account on this device, not only its session: the
  /// account is disabled, or the password the device keeps is no longer its own.
  static const _accountEnded = {'USER_DISABLED', 'INVALID_CREDENTIALS'};

  /// A revalidation that may sign in again with the unlock password.
  Future<void>? _revalidating;

  @override
  AuthState build() => const AuthUnknown();

  SecureStore get _store => ref.read(secureStoreProvider);
  AuthApi get _api => ref.read(authApiProvider);
  TokenRefresher get _refresher => ref.read(tokenRefresherProvider);
  PasswordVerifier get _verifier => ref.read(verifierProvider);
  DateTime _now() => ref.read(clockProvider)().toUtc();
  ProfileStore get _profiles => ProfileStore(ref.read(databaseProvider));

  /// Whether this device is the whole shop, with no server behind it.
  bool get _standalone => ref.read(standaloneProvider);

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
    } catch (e, st) {
      state = AuthLoggedOut(error: _notSaved(e, st), returnTo: returnTo);
    }
  }

  /// The server answered, but the device could not keep the sign-in (a locked
  /// keychain, a failing database): say so rather than leave a spinner.
  String _notSaved(Object e, StackTrace st) {
    developer.log('sign-in could not be saved', name: 'auth', error: e, stackTrace: st);
    return 'STORAGE_UNAVAILABLE';
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
    } catch (e, st) {
      state = AuthLoggedOut(error: _notSaved(e, st));
    }
  }

  /// Set up a shop that has no server: this device keeps the owner account and
  /// the shop's books, and never calls anywhere. The mode is written before the
  /// account, so a device interrupted halfway starts over rather than coming
  /// back as a half-built shop with a server.
  ///
  /// Nothing set up here can be recovered from a server afterwards, because
  /// there is none: a forgotten password is a shop locked out of its own books.
  /// The setup screen says so before this is chosen.
  Future<void> setupStandalone({
    required String username,
    required String password,
    required String displayName,
    required String shopName,
  }) async {
    try {
      assertPasswordStrong(password: password);
      ref.read(appModeProvider.notifier).set(AppMode.standalone);
      final userId = newId();
      final branchId = newId();
      await _dropQuickUnlocksOf(userId);
      await _store.write(SecureKeys.passwordVerifier, await _verifier.derive(password));
      await _markValidated();
      await _profiles.replace(
        userId: userId,
        username: username,
        displayName: displayName,
        defaultBranchId: branchId,
        // The shop is its own single branch, and whoever sets it up owns it.
        branches: [
          {'branch_id': branchId, 'branch_name': shopName, 'role_name': 'owner'},
        ],
      );
      final profile = await _profiles.current();
      if (profile != null) state = AuthLoggedIn(profile);
    } on ValidationError catch (e) {
      state = AuthLoggedOut(error: e.code);
    } catch (e, st) {
      state = AuthLoggedOut(error: _notSaved(e, st));
    }
  }

  CachedProfileRow? get _returnTo {
    final s = state;
    return s is AuthLoggedOut ? s.returnTo : null;
  }

  Future<void> unlockWithPassword(String password) =>
      _unlock(SecureKeys.passwordVerifier, password);

  /// A quick unlock needs a live session: once the server has ended it, only
  /// the password unlocks, because only the password can sign in again.
  Future<void> unlockWithPin(String pin) async {
    if (!await _hasSession()) {
      final profile = await _profiles.current();
      state = profile == null ? const AuthLoggedOut() : AuthLocked(profile, error: 'PASSWORD_REQUIRED');
      return;
    }
    await _unlock(SecureKeys.pinVerifier, pin);
  }

  /// In a shop with no server nothing can end a session: the device itself is
  /// the authority, so a PIN or a fingerprint always has one behind it.
  Future<bool> _hasSession() async =>
      _standalone || await _store.read(SecureKeys.refreshToken) != null;

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
    // The window is the server's rule: how long a device may keep unlocking
    // before the server confirms the user again. A shop with no server has
    // nothing to confirm against, and so no window to run out.
    if (_standalone) return true;
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
  /// by default, so another fingerprint enrolled on a shared till opens nothing. [reason] is the system prompt's text, in the app's language.
  Future<bool> unlockWithBiometric(String reason) async {
    final profile = await _profiles.current();
    if (profile == null || !await biometricEnabled()) return false;
    if (!await ref.read(biometricProvider).authenticate(reason)) return false;
    if (!await _offlineAllowed()) {
      state = const AuthLoggedOut(error: 'OFFLINE_EXPIRED');
      return false;
    }
    state = AuthLoggedIn(profile, offline: true);
    return true;
  }

  /// Whether the fingerprint may unlock: the cached user opted in, and (as for
  /// a PIN) the session is live.
  Future<bool> biometricEnabled() async {
    final profile = await _profiles.current();
    return profile != null &&
        await _store.read(SecureKeys.biometricUser) == profile.userId &&
        await _hasSession();
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
  Future<void> revalidate({String? password}) {
    if (_standalone) return Future.value(); // nothing to confirm against
    if (password == null) return _revalidate(null);
    // Meanwhile, a request that finds the old session over waits for this
    // (see sessionEnded).
    return _revalidating ??= _revalidate(password).whenComplete(() => _revalidating = null);
  }

  Future<void> _revalidate(String? password) async {
    if (state is! AuthLoggedIn) return;
    try {
      // The server ended this session earlier (see _end): only the password
      // signs in again.
      if (!await _hasSession()) throw const AuthApiException('REFRESH_INVALID');
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
      if (failed != null) await _end(failed);
    } on NetworkException {
      // Offline: keep working from the cache.
    } on StaleSessionException {
      // Signed out, or another user signed in, meanwhile: nothing to confirm.
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
      return _accountEnded.contains(e.code) ? e.code : ended;
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

  /// A request found its session over (from the [TokenRefresher], with the
  /// session it was sent in). While the unlock password may be signing in again,
  /// that decides: an answer meant for the session it replaced is dropped. Safe
  /// to call more than once.
  Future<void> sessionEnded(String code, {int? epoch}) async {
    final pending = _revalidating;
    if (pending != null) {
      try {
        await pending;
      } catch (_) {
        // Its outcome is in the state; this answer still counts below.
      }
    }
    if (epoch != null && epoch != _refresher.epoch) return;
    await _end(code);
  }

  /// Ends the saved session. When only the session ended (expired, revoked, a
  /// token rotated out), the account may be fine: the device keeps the user and
  /// the password, so the till still unlocks offline within its window, and the
  /// next password unlock signs in again. When the account ended, or the
  /// password is no longer its own, nothing is left to unlock with.
  Future<void> _end(String code) async {
    final s = state;
    if (s is AuthLoggedOut || s is AuthUnknown) return;
    final profile = await _profiles.current();
    final keepsPassword = await _store.read(SecureKeys.passwordVerifier) != null;
    if (_accountEnded.contains(code) || profile == null || !keepsPassword) {
      await _forget();
      state = AuthLoggedOut(error: code);
      return;
    }
    await _refresher.newSession(() async {
      await _store.delete(SecureKeys.refreshToken);
      await _store.delete(SecureKeys.accessToken);
    });
    state = AuthLocked(profile, error: code);
  }

  /// Sign out: wipe the device first, then tell the server best-effort, so a
  /// bad connection never keeps the app signed in. The server ends the session
  /// with this token, or with the one a renewal still in flight rotates it to.
  Future<void> logout() async {
    // In a shop with no server this is the only account on the only device, and
    // wiping it would lock the shop out of its own books with nobody left to
    // let it back in. The shell offers Lock there instead of sign-out.
    if (_standalone) return;
    final refresh = await _store.read(SecureKeys.refreshToken);
    await _forget();
    state = const AuthLoggedOut();
    if (refresh != null) unawaited(_api.logout(refresh));
  }

  /// Remove every trace of the signed-in user from this device. The outbox
  /// stays: it syncs when its recorder signs in again.
  Future<void> _forget() async {
    await _refresher.newSession(() async {
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
    });
    await _profiles.clear();
  }

  /// A PIN and a fingerprint belong to the one user who set them up on this
  /// device: when somebody else takes it over, they go.
  Future<void> _dropQuickUnlocksOf(String userId) async {
    final previous = await _profiles.current();
    if (previous == null || previous.userId == userId) return;
    await _store.delete(SecureKeys.pinVerifier);
    await _store.delete(SecureKeys.biometricUser);
  }

  Future<CachedProfileRow?> _persist(ApiAuthResult res, String password) async {
    await _dropQuickUnlocksOf(res.user.id);
    await _refresher.newSession(() async {
      await _store.write(SecureKeys.refreshToken, res.tokens.refreshToken);
      await _store.write(SecureKeys.accessToken, res.tokens.accessToken);
    });
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
