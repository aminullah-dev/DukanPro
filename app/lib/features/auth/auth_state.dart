import 'package:dukan_data/dukan_data.dart' show CachedProfileRow;

/// Auth state drives routing. `profile` is the cached, denormalised server
/// profile (the server is authoritative).
sealed class AuthState {
  const AuthState();
}

/// Startup — restoring from cache.
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// No cached session — must sign in online.
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut({this.error, this.canReturn = false});
  final String? error; // error code, e.g. INVALID_CREDENTIALS / NETWORK

  /// Signing in as someone else from the lock screen: the cached session is
  /// kept, and the login screen offers the way back to it.
  final bool canReturn;
}

/// A session is cached but the app is locked — unlock with password/PIN/biometric.
class AuthLocked extends AuthState {
  const AuthLocked(this.profile, {this.error});
  final CachedProfileRow profile;
  final String? error;
}

/// Signed in. `offline` when unlocked without a fresh server login.
class AuthLoggedIn extends AuthState {
  const AuthLoggedIn(this.profile, {this.offline = false});
  final CachedProfileRow profile;
  final bool offline;
}
