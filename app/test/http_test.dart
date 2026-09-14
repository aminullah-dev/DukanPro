import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dukanpro/infrastructure/auth_api.dart';
import 'package:dukanpro/infrastructure/http.dart';
import 'package:dukanpro/infrastructure/secure_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// An API whose only valid access token is [valid]: any other bearer gets
/// 401 TOKEN_EXPIRED, and every request gets [endedCode] once that is set.
class _Api implements HttpClientAdapter {
  String valid = 'a2';
  String? endedCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(Duration.zero); // let concurrent requests overlap
    final bearer = (options.headers['authorization'] as String?)?.substring('Bearer '.length);
    final code = endedCode ?? (bearer == valid ? null : 'TOKEN_EXPIRED');
    return ResponseBody.fromString(
      jsonEncode(code == null ? {'ok': true} : {'error': {'code': code, 'context': {}}}),
      code == null ? 200 : 401,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Renews slowly, so requests that fail together overlap the renewal.
class _SlowAuth extends FakeAuthApi {
  Exception? failWith;

  @override
  Future<ApiTokens> refresh(String refreshToken) async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (failWith case final e?) throw e;
    return const ApiTokens(accessToken: 'a2', refreshToken: 'r2');
  }
}

void main() {
  late FakeSecureStore store;
  late _SlowAuth auth;
  late _Api server;
  late Dio dio;
  late List<String> ended;

  setUp(() async {
    store = FakeSecureStore();
    await store.write(SecureKeys.accessToken, 'a1');
    await store.write(SecureKeys.refreshToken, 'r1');
    auth = _SlowAuth();
    ended = [];
    final refresher = TokenRefresher(store: store, api: auth)..onSessionEnded = (code, _) => ended.add(code);
    server = _Api();
    dio = authedDio('http://api.test', store: store, refresher: refresher)..httpClientAdapter = server;
  });

  test('an expired token is renewed once for requests that fail together', () async {
    final answers = await Future.wait([for (var i = 0; i < 3; i++) dio.get<dynamic>('/x')]);
    expect(answers.map((r) => r.statusCode), [200, 200, 200]);
    expect(auth.refreshCalls, 1);
    expect(await store.read(SecureKeys.accessToken), 'a2');
    expect(await store.read(SecureKeys.refreshToken), 'r2');
  });

  test('a session the server ended sends the app to sign-in, not offline', () async {
    auth.failWith = const AuthApiException('REFRESH_INVALID', statusCode: 401);
    await expectLater(
      dio.get<dynamic>('/x'),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 401)),
    );
    expect(ended, ['REFRESH_INVALID']);
  });

  test('a disabled account is reported from any request', () async {
    server.endedCode = 'USER_DISABLED';
    await expectLater(dio.get<dynamic>('/x'), throwsA(isA<DioException>()));
    expect(ended, ['USER_DISABLED']);
    expect(auth.refreshCalls, 0);
  });

  test('a renewal that cannot reach the server fails the request as offline', () async {
    auth.failWith = const NetworkException();
    await expectLater(
      dio.get<dynamic>('/x'),
      throwsA(isA<DioException>().having((e) => e.response, 'response', isNull)),
    );
    expect(ended, isEmpty);
    expect(await store.read(SecureKeys.refreshToken), 'r1');
  });

  test('every client times out instead of hanging', () {
    final options = newDio('http://api.test').options;
    expect(options.connectTimeout, isNotNull);
    expect(options.receiveTimeout, isNotNull);
  });
}
