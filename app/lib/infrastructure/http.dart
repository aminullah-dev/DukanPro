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

/// Renews the access token with the refresh token, one renewal at a time. The
/// server rotates the refresh token on every refresh, so two renewals racing
/// with the same token would leave the device holding a rotated-out one:
/// callers that need a new token together share one renewal.
class TokenRefresher {
  TokenRefresher({required this.store, required this.api});
  final SecureStore store;
  final AuthApi api;

  /// Told when a background request finds the session over (set when the app
  /// is wired): the app then asks for an online sign-in.
  void Function(String code)? onSessionEnded;

  Future<String>? _renewal;

  /// An access token to use instead of [stale]. Throws [AuthApiException] when
  /// the server no longer accepts the session, [NetworkException] offline.
  Future<String> renew(String? stale) =>
      _renewal ??= _renew(stale).whenComplete(() => _renewal = null);

  Future<String> _renew(String? stale) async {
    final current = await store.read(SecureKeys.accessToken);
    if (current != null && current != stale) return current; // renewed meanwhile
    final refresh = await store.read(SecureKeys.refreshToken);
    if (refresh == null) throw const AuthApiException('REFRESH_INVALID');
    final tokens = await api.refresh(refresh);
    // The refresh token first: the server has already rotated the old one out.
    await store.write(SecureKeys.refreshToken, tokens.refreshToken);
    await store.write(SecureKeys.accessToken, tokens.accessToken);
    return tokens.accessToken;
  }
}

/// Sends the saved access token with every request. A 401 `TOKEN_EXPIRED`
/// renews it once through the [TokenRefresher] and retries the request. An
/// answer that the session is over goes to [TokenRefresher.onSessionEnded]
/// instead of looking like a network failure.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.store, required this.refresher});
  final Dio dio;
  final SecureStore store;
  final TokenRefresher refresher;

  static const _retried = 'dukan.retried';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await store.read(SecureKeys.accessToken);
    if (token != null) options.headers['authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final code = err.response?.statusCode == 401 ? errorCode(err) : null;
    if (code != null && sessionEndedCodes.contains(code)) {
      refresher.onSessionEnded?.call(code);
    }
    if (code != 'TOKEN_EXPIRED' || err.requestOptions.extra[_retried] == true) {
      handler.next(err);
      return;
    }
    final sent = err.requestOptions.headers['authorization'] as String?;
    try {
      final fresh = await refresher.renew(sent?.substring('Bearer '.length));
      final retry = err.requestOptions
        ..headers['authorization'] = 'Bearer $fresh'
        ..extra[_retried] = true;
      handler.resolve(await dio.fetch<dynamic>(retry));
    } on AuthApiException catch (e) {
      if (sessionEndedCodes.contains(e.code)) refresher.onSessionEnded?.call(e.code);
      handler.next(err);
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
