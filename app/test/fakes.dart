import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:dukanpro/infrastructure/auth_api.dart';
import 'package:dukanpro/infrastructure/secure_store.dart';
import 'package:dukanpro/infrastructure/verifier.dart';

/// In-memory secure store for tests (no platform channels).
class FakeSecureStore implements SecureStore {
  final Map<String, String> _m = {};
  @override
  Future<void> write(String key, String value) async => _m[key] = value;
  @override
  Future<String?> read(String key) async => _m[key];
  @override
  Future<void> delete(String key) async => _m.remove(key);
}

/// Fast, deterministic verifier for controller tests (real argon2 is covered
/// by verifier_test.dart).
class FakeVerifier implements PasswordVerifier {
  @override
  Future<String> derive(String secret) async => 'v:$secret';
  @override
  Future<bool> verify(String secret, String stored) async => stored == 'v:$secret';
}

/// Canned auth API. Password "correct" succeeds; anything else is rejected.
class FakeAuthApi implements AuthApi {
  static ApiProfile _profile(String username) => ApiProfile(
        id: 'u1',
        username: username,
        displayName: 'Owner',
        defaultBranchId: 'b1',
        branches: const [BranchRoleDto(branchId: 'b1', branchName: 'Main', roleName: 'owner')],
      );

  static ApiAuthResult _result(String username) => ApiAuthResult(
        user: _profile(username),
        tokens: const ApiTokens(accessToken: 'a1', refreshToken: 'r1'),
      );

  @override
  Future<ApiAuthResult> login({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    if (password != 'correct') {
      throw const AuthApiException('INVALID_CREDENTIALS', statusCode: 401);
    }
    return _result(username);
  }

  @override
  Future<ApiAuthResult> bootstrap({
    required String username,
    required String password,
    required String displayName,
    required String shopName,
    required String deviceId,
  }) async =>
      _result(username);

  @override
  Future<ApiTokens> refresh(String refreshToken) async =>
      const ApiTokens(accessToken: 'a2', refreshToken: 'r2');

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<ApiProfile> me(String accessToken) async => _profile('owner');
}

/// In-memory [SyncClient]: records pushed ops (all applied) and pulls nothing.
class FakeSyncClient implements SyncClient {
  final List<OutboxOp> pushed = [];

  @override
  Future<List<PushResult>> push(List<OutboxOp> ops) async {
    pushed.addAll(ops);
    return [for (final o in ops) PushResult(o.opId, OpOutcome.applied)];
  }

  @override
  Future<PullResult> pull({required int sinceWatermark}) async =>
      const PullResult(watermark: 0, changed: [], tombstones: []);
}
