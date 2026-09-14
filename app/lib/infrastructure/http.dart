import 'dart:async';

import 'package:dio/dio.dart';

import 'auth_api.dart';
import 'secure_store.dart';

/// Every API client's [Dio]: requests time out, so a half-open mobile
/// connection fails as offline instead of hanging a spinner or a sync.
Dio newDio(String baseUrl) => Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

/// A [newDio] that sends the saved access token and renews it when it expires.
Dio authedDio(String baseUrl, {required SecureStore store, required TokenRefresher refresher}) {
  final dio = newDio(baseUrl);
  dio.interceptors.add(AuthInterceptor(dio: dio, store: store, refresher: refresher));
  return dio;
}

/// Riverpod retry policy for server-backed providers: a network failure is
/// retried a few times with a short backoff; an answer from the server (a
/// refusal, a validation error) is final and shown at once.
Duration? retryWhenOffline(int retryCount, Object error) =>
    error is NetworkException && retryCount < 3 ? Duration(milliseconds: 400 << retryCount) : null;

/// Server answers meaning this account or session is no longer accepted.
const sessionEndedCodes = {'USER_DISABLED', 'SESSION_REVOKED', 'REFRESH_INVALID', 'TOKEN_INVALID'};

/// The code of a structured server error (`{error: {code}}`), if there is one.
String? errorCode(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['error'] is Map) return (data['error'] as Map)['code'] as String?;
  return null;
}

/// A request or renewal made in a session that has since ended or been
/// replaced: its answer must not touch the current one.
class StaleSessionException implements Exception {
  const StaleSessionException();

  @override
  String toString() => 'StaleSessionException';
}

/// Renews the access token with the refresh token, one renewal at a time. The
/// server rotates the refresh token on every refresh, so two renewals racing
/// with the same token would leave the device holding a rotated-out one:
/// callers that need a new token together share one renewal.
///
/// Every sign-in and sign-out starts a new [epoch], and a request remembers the
/// epoch it was sent in. An answer that arrives after the till changed hands (a
/// renewed token, "account disabled") is dropped instead of acting on the next
/// session. Token writes (sign-in, sign-out, renewal) run one at a time, so a
/// renewal never writes its tokens back after a sign-out.
class TokenRefresher {
  TokenRefresher({
    required this.store,
    required this.api,
    this.retryDelays = const [Duration(seconds: 1)],
  });
  final SecureStore store;
  final AuthApi api;

  /// Pauses before asking again when a refresh got no answer. The server may
  /// have rotated the token all the same, and it takes the rotated-out one back
  /// only for a minute after that (REFRESH_RETRY_GRACE).
  final List<Duration> retryDelays;

  /// Told when a request sent in session `epoch` finds that session over (set
  /// when the app is wired).
  void Function(String code, int epoch)? onSessionEnded;

  int _epoch = 0;
  Future<String>? _renewal;
  Future<void> _writes = Future.value();

  /// The session the saved tokens belong to.
  int get epoch => _epoch;

  Future<T> _serially<T>(Future<T> Function() body) {
    final result = _writes.then((_) => body());
    _writes = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  /// Starts a new session: [write] saves its tokens (a sign-in) or removes them
  /// (a sign-out). The previous session's requests and renewals no longer count.
  Future<void> newSession(Future<void> Function() write) => _serially(() async {
        _epoch++;
        _renewal = null;
        await write();
      });

  /// Reports [code] for a request sent in session [epoch], unless that session
  /// is over already.
  void ended(String code, int epoch) {
    if (epoch == _epoch) onSessionEnded?.call(code, epoch);
  }

  /// An access token to use instead of [stale], for a request of session
  /// [epoch] (the current one when null). Throws [AuthApiException] when the
  /// server no longer accepts the session, [NetworkException] offline, and
  /// [StaleSessionException] once the session has changed.
  Future<String> renew(String? stale, {int? epoch}) {
    final session = epoch ?? _epoch;
    if (session != _epoch) return Future.error(const StaleSessionException());
    final pending = _renewal;
    if (pending != null) return pending;
    late final Future<String> renewal;
    renewal = _renew(stale, session).whenComplete(() {
      if (identical(_renewal, renewal)) _renewal = null;
    });
    return _renewal = renewal;
  }

  Future<String> _renew(String? stale, int session) async {
    final current = await store.read(SecureKeys.accessToken);
    if (current != null && current != stale) return current; // renewed meanwhile
    final refresh = await store.read(SecureKeys.refreshToken);
    if (refresh == null) throw const AuthApiException('REFRESH_INVALID');
    final tokens = await _refresh(refresh);
    return _serially(() async {
      if (session != _epoch) throw const StaleSessionException();
      // The refresh token first: the server has already rotated the old one out.
      await store.write(SecureKeys.refreshToken, tokens.refreshToken);
      await store.write(SecureKeys.accessToken, tokens.accessToken);
      return tokens.accessToken;
    });
  }

  /// A refresh whose answer never came may still have rotated the token on the
  /// server: ask again at once, while the server still takes the old one.
  Future<ApiTokens> _refresh(String refresh) async {
    for (var attempt = 0;; attempt++) {
      try {
        return await api.refresh(refresh);
      } on NetworkException catch (e) {
        if (!e.maybeDelivered || attempt >= retryDelays.length) rethrow;
        await Future<void>.delayed(retryDelays[attempt]);
      }
    }
  }
}

/// Sends the saved access token with every request. A 401 `TOKEN_EXPIRED`
/// renews it once through the [TokenRefresher] and retries the request. An
/// answer that the session is over goes to [TokenRefresher.ended] instead of
/// looking like a network failure. Each request carries the session it was
/// sent in: a retry never goes out with the next user's token.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.store, required this.refresher});
  final Dio dio;
  final SecureStore store;
  final TokenRefresher refresher;

  static const _retried = 'dukan.retried';
  static const _session = 'dukan.session';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final session = options.extra[_session] as int? ?? refresher.epoch;
    if (session != refresher.epoch) {
      handler.reject(DioException(requestOptions: options, error: const StaleSessionException()));
      return;
    }
    options.extra[_session] = session;
    final token = await store.read(SecureKeys.accessToken);
    if (token != null) options.headers['authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final session = err.requestOptions.extra[_session] as int? ?? refresher.epoch;
    final code = err.response?.statusCode == 401 ? errorCode(err) : null;
    if (code != null && sessionEndedCodes.contains(code)) refresher.ended(code, session);
    if (code != 'TOKEN_EXPIRED' || err.requestOptions.extra[_retried] == true) {
      handler.next(err);
      return;
    }
    final sent = err.requestOptions.headers['authorization'] as String?;
    try {
      final fresh = await refresher.renew(sent?.substring('Bearer '.length), epoch: session);
      final retry = err.requestOptions
        ..headers['authorization'] = 'Bearer $fresh'
        ..extra[_retried] = true;
      handler.resolve(await dio.fetch<dynamic>(retry));
    } on AuthApiException catch (e) {
      if (sessionEndedCodes.contains(e.code)) refresher.ended(e.code, session);
      handler.next(err);
    } on StaleSessionException {
      handler.next(err); // the session changed meanwhile: this answer is no one's
    } on NetworkException {
      handler.next(DioException.connectionError(
        requestOptions: err.requestOptions,
        reason: 'the access token could not be renewed',
      ));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
