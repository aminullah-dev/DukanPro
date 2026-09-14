// Token renewal races (review of themes 3-5): an answer that arrives after the
// session changed is dropped, a concurrent request does not undo the password
// re-sign-in, a lost refresh answer is asked for again at once, and a session
// the server ended anyway leaves the till unlockable offline with the password.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/auth_controller.dart';
import 'package:dukanpro/features/auth/auth_state.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/infrastructure/auth_api.dart';
import 'package:dukanpro/infrastructure/http.dart';
import 'package:dukanpro/infrastructure/secure_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// An API server that accepts only [valid] as bearer; any other gets 401
/// TOKEN_EXPIRED.
class _Server implements HttpClientAdapter {
  String? valid;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final bearer = (options.headers['authorization'] as String?)?.substring('Bearer '.length);
    final ok = valid != null && bearer == valid;
    return ResponseBody.fromString(
      jsonEncode(ok ? {'ok': true} : {'error': {'code': 'TOKEN_EXPIRED', 'context': {}}}),
      ok ? 200 : 401,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Answers [disabledBearer] with 401 USER_DISABLED after a slow 150 ms; others 200.
class _SlowDisabled implements HttpClientAdapter {
  String? disabledBearer;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bearer = (options.headers['authorization'] as String?)?.substring('Bearer '.length);
    final ended = bearer == disabledBearer;
    await Future<void>.delayed(Duration(milliseconds: ended ? 150 : 5));
    return ResponseBody.fromString(
      jsonEncode(ended ? {'error': {'code': 'USER_DISABLED', 'context': {}}} : {'ok': true}),
      ended ? 401 : 200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Refresh and sign-in take a little network time; each test scripts the answers.
class _ScriptedAuth extends FakeAuthApi {
  Exception? refreshError;
  ApiTokens refreshTokens = const ApiTokens(accessToken: 'a2', refreshToken: 'r2');
  final Map<String, ApiTokens> loginTokens = {};
  final List<String> loggedOutWith = [];
  Duration refreshDelay = const Duration(milliseconds: 30);

  @override
  Future<ApiTokens> refresh(String refreshToken) async {
    refreshCalls++;
    await Future<void>.delayed(refreshDelay);
    if (refreshError case final e?) throw e;
    return refreshTokens;
  }

  @override
  Future<ApiAuthResult> login({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final res = await super.login(username: username, password: password, deviceId: deviceId);
    final t = loginTokens[username];
    return t == null ? res : ApiAuthResult(user: res.user, tokens: t);
  }

  @override
  Future<void> logout(String refreshToken) async => loggedOutWith.add(refreshToken);
}

/// auth_service.refresh as a fake: rotation in place; a rotated-out token is
/// taken again only within 60 s, otherwise the session is revoked.
/// [loseNextAnswer] rotates on the server, but the answer never arrives.
class _GraceServerAuth extends FakeAuthApi {
  DateTime now = DateTime.utc(2026, 9, 14, 10);
  String current = 'r1';
  String? previous;
  DateTime rotatedAt = DateTime.utc(2026, 9, 14, 10);
  bool revoked = false;
  bool loseNextAnswer = false;
  int _n = 1;

  @override
  Future<ApiTokens> refresh(String refreshToken) async {
    refreshCalls++;
    if (revoked) throw const AuthApiException('REFRESH_INVALID', statusCode: 401);
    if (refreshToken != current &&
        (refreshToken != previous || now.difference(rotatedAt) > const Duration(seconds: 60))) {
      revoked = true; // reuse detected
      throw const AuthApiException('REFRESH_INVALID', statusCode: 401);
    }
    previous = current;
    current = 'r${++_n}';
    rotatedAt = now;
    if (loseNextAnswer) {
      loseNextAnswer = false;
      throw const NetworkException(maybeDelivered: true); // the answer timed out
    }
    return ApiTokens(accessToken: 'a$_n', refreshToken: current);
  }
}

/// Secure storage that reads but cannot write (a locked keychain).
class _UnwritableStore extends FakeSecureStore {
  @override
  Future<void> write(String key, String value) async =>
      throw Exception('PlatformException(-25308, errSecInteractionNotAllowed)');
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  ({ProviderContainer c, Dio dio, _Server server}) wire(FakeSecureStore store, FakeAuthApi api) {
    final c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      secureStoreProvider.overrideWithValue(store),
      authApiProvider.overrideWithValue(api),
      verifierProvider.overrideWithValue(FakeVerifier()),
      tokenRefresherProvider.overrideWith(
          (ref) => TokenRefresher(store: store, api: api, retryDelays: const [Duration.zero])),
    ]);
    addTearDown(c.dispose);
    // As main.dart wires it.
    final refresher = c.read(tokenRefresherProvider);
    refresher.onSessionEnded = (code, epoch) =>
        unawaited(c.read(authControllerProvider.notifier).sessionEnded(code, epoch: epoch));
    final server = _Server();
    final dio = authedDio('http://api.test', store: store, refresher: refresher)..httpClientAdapter = server;
    return (c: c, dio: dio, server: server);
  }

  Future<Object?> answer(Future<Response<dynamic>> request) =>
      request.then<Object?>((r) => r.statusCode, onError: (Object _) => 'failed');

  test('a request that meets the ended session waits for the password re-sign-in', () async {
    final store = FakeSecureStore();
    final api = _ScriptedAuth()..loginTokens['owner'] = const ApiTokens(accessToken: 'a1', refreshToken: 'r1');
    final w = wire(store, api);
    final controller = w.c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    controller.lock();

    // Days later the session has ended on the server; the password still works.
    api
      ..meErrors.add('TOKEN_EXPIRED')
      ..refreshError = const AuthApiException('REFRESH_INVALID', statusCode: 401)
      ..loginTokens['owner'] = const ApiTokens(accessToken: 'a9', refreshToken: 'r9');
    await controller.unlockWithPassword('correct');
    // The unlock screen revalidates; the shell's notifications bell loads meanwhile.
    final revalidation = controller.revalidate(password: 'correct');
    await Future<void>.delayed(const Duration(milliseconds: 1));
    await answer(w.dio.get<dynamic>('/notifications'));
    await revalidation;
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(w.c.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(await store.read(SecureKeys.refreshToken), 'r9');
  });

  test('a renewal that ends after sign-out writes nothing back', () async {
    final store = FakeSecureStore();
    final api = _ScriptedAuth()..loginTokens['owner'] = const ApiTokens(accessToken: 'a1', refreshToken: 'r1');
    final w = wire(store, api);
    final controller = w.c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    w.server.valid = 'a2'; // a1 expired; the renewal will bring a2/r2

    final request = answer(w.dio.get<dynamic>('/sync/pull'));
    await Future<void>.delayed(const Duration(milliseconds: 10)); // the renewal is in flight
    await controller.logout();
    expect(await request, 'failed');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(await store.read(SecureKeys.refreshToken), isNull);
    expect(await store.read(SecureKeys.accessToken), isNull);
    expect(api.loggedOutWith, ['r1']); // the server ends the session with r1 or its r2
  });

  test("the previous user's renewal never overwrites the next user's sign-in", () async {
    final store = FakeSecureStore();
    final api = _ScriptedAuth()
      ..loginTokens['owner'] = const ApiTokens(accessToken: 'a1', refreshToken: 'r1')
      ..loginTokens['bob'] = const ApiTokens(accessToken: 'aB', refreshToken: 'rB');
    final w = wire(store, api);
    final controller = w.c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    w.server.valid = 'a2';
    api.refreshDelay = const Duration(milliseconds: 120); // a slow mobile network

    final request = answer(w.dio.get<dynamic>('/sync/pull'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    controller
      ..lock()
      ..useAnotherAccount();
    await controller.loginOnline(username: 'bob', password: 'correct');
    expect(await request, 'failed');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final state = w.c.read(authControllerProvider);
    expect((state as AuthLoggedIn).profile.username, 'bob');
    expect(await store.read(SecureKeys.refreshToken), 'rB');
    expect(await store.read(SecureKeys.accessToken), 'aB');
  });

  test("a late 'account disabled' for the previous user leaves the next one signed in", () async {
    final store = FakeSecureStore();
    final api = _ScriptedAuth()
      ..loginTokens['owner'] = const ApiTokens(accessToken: 'a1', refreshToken: 'r1')
      ..loginTokens['bob'] = const ApiTokens(accessToken: 'aB', refreshToken: 'rB');
    final w = wire(store, api);
    w.dio.httpClientAdapter = _SlowDisabled()..disabledBearer = 'a1';
    final controller = w.c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');

    final request = answer(w.dio.get<dynamic>('/sync/pull'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    controller
      ..lock()
      ..useAnotherAccount();
    await controller.loginOnline(username: 'bob', password: 'correct');
    await request; // the owner's answer: 401 USER_DISABLED
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(w.c.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(await store.read(SecureKeys.refreshToken), 'rB');
  });

  test('a sign-in that cannot be saved says so instead of spinning', () async {
    final c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      secureStoreProvider.overrideWithValue(_UnwritableStore()),
      authApiProvider.overrideWithValue(FakeAuthApi()),
      verifierProvider.overrideWithValue(FakeVerifier()),
    ]);
    addTearDown(c.dispose);
    await c.read(authControllerProvider.notifier).loginOnline(username: 'owner', password: 'correct');
    expect((c.read(authControllerProvider) as AuthLoggedOut).error, 'STORAGE_UNAVAILABLE');
  });

  test('a refresh answer lost on the way is asked for again at once', () async {
    final store = FakeSecureStore();
    final api = _GraceServerAuth();
    final w = wire(store, api);
    await w.c.read(authControllerProvider.notifier).loginOnline(username: 'owner', password: 'correct');
    w.server.valid = 'a3';
    api.loseNextAnswer = true; // the server rotates r1 to r2, but the answer times out

    expect(await answer(w.dio.get<dynamic>('/sync/pull')), 200);
    expect(await store.read(SecureKeys.refreshToken), 'r3');
    expect(api.revoked, isFalse);
  });

  test('a session the server ended anyway still unlocks offline with the password', () async {
    final store = FakeSecureStore();
    final api = _GraceServerAuth();
    final w = wire(store, api);
    final controller = w.c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    await controller.enableBiometric('correct');
    // Every renewal was lost past the grace: the server has revoked the session.
    api.revoked = true;

    expect(await answer(w.dio.get<dynamic>('/sync/pull')), 'failed');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final state = w.c.read(authControllerProvider);
    expect((state as AuthLocked).error, 'REFRESH_INVALID');
    expect(await store.read(SecureKeys.refreshToken), isNull);
    expect(await store.read(SecureKeys.passwordVerifier), isNotNull);
    expect(await controller.biometricEnabled(), isFalse); // the password is needed to sign in again
    await controller.unlockWithPassword('correct');
    expect(w.c.read(authControllerProvider), isA<AuthLoggedIn>());
  });
}
