import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:dukanpro/infrastructure/auth_api.dart';
import 'package:dukanpro/infrastructure/iam_api.dart';
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

/// In-memory [IamApi]: mirrors the server's employee/branch admin semantics
/// closely enough for controller and screen tests (no network, no auth).
class FakeIamApi implements IamApi {
  FakeIamApi({List<EmployeeDto>? employees, List<BranchDto>? branches})
      : _employees = employees ?? [],
        _branches = branches ?? [const BranchDto(
              id: 'b1', name: 'Main', timezone: 'Asia/Kabul', currencyDefault: 'AFN', isActive: true,
            )];
  final List<EmployeeDto> _employees;
  final List<BranchDto> _branches;
  int _seq = 0;

  EmployeeDto _replace(EmployeeDto updated) {
    final i = _employees.indexWhere((e) => e.id == updated.id);
    if (i >= 0) _employees[i] = updated;
    return updated;
  }

  @override
  Future<List<EmployeeDto>> listEmployees() async => List.of(_employees);

  @override
  Future<EmployeeDto> createEmployee({
    required String username,
    required String password,
    required String displayName,
    required String roleName,
  }) async {
    final e = EmployeeDto(
      id: 'u${++_seq}', username: username, displayName: displayName, status: 'active',
      defaultBranchId: 'b1',
      branches: [BranchRoleDto(branchId: 'b1', branchName: 'Main', roleName: roleName)],
    );
    _employees.add(e);
    return e;
  }

  @override
  Future<EmployeeDto> setEmployeeStatus(String userId, {required bool active}) async {
    final e = _employees.firstWhere((x) => x.id == userId);
    return _replace(EmployeeDto(
      id: e.id, username: e.username, displayName: e.displayName,
      status: active ? 'active' : 'disabled', defaultBranchId: e.defaultBranchId, branches: e.branches,
    ));
  }

  @override
  Future<EmployeeDto> assignRole(String userId, {required String branchId, required String roleName}) async {
    final e = _employees.firstWhere((x) => x.id == userId);
    final branches = [
      ...e.branches.where((b) => b.branchId != branchId),
      BranchRoleDto(branchId: branchId, branchName: 'Branch', roleName: roleName),
    ];
    return _replace(EmployeeDto(
      id: e.id, username: e.username, displayName: e.displayName, status: e.status,
      defaultBranchId: e.defaultBranchId, branches: branches,
    ));
  }

  @override
  Future<EmployeeDto> revokeAssignment(String userId, String branchId) async {
    final e = _employees.firstWhere((x) => x.id == userId);
    return _replace(EmployeeDto(
      id: e.id, username: e.username, displayName: e.displayName, status: e.status,
      defaultBranchId: e.defaultBranchId,
      branches: e.branches.where((b) => b.branchId != branchId).toList(),
    ));
  }

  @override
  Future<void> resetPassword(String userId, String newPassword) async {}

  @override
  Future<List<BranchDto>> listBranches() async => List.of(_branches);

  @override
  Future<BranchDto> createBranch(String name) async {
    final b = BranchDto(
      id: 'b${++_seq}', name: name, timezone: 'Asia/Kabul', currencyDefault: 'AFN', isActive: true,
    );
    _branches.add(b);
    return b;
  }

  @override
  Future<BranchDto> renameBranch(String branchId, String name) async {
    final i = _branches.indexWhere((b) => b.id == branchId);
    final b = _branches[i];
    return _branches[i] = BranchDto(
      id: b.id, name: name, timezone: b.timezone, currencyDefault: b.currencyDefault, isActive: b.isActive,
    );
  }

  @override
  Future<BranchDto> setBranchActive(String branchId, {required bool active}) async {
    final i = _branches.indexWhere((b) => b.id == branchId);
    final b = _branches[i];
    return _branches[i] = BranchDto(
      id: b.id, name: b.name, timezone: b.timezone, currencyDefault: b.currencyDefault, isActive: active,
    );
  }
}
