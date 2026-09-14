import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/http.dart' show retryWhenOffline;
import '../../infrastructure/iam_api.dart';
import '../auth/session.dart';

/// The employee/branch admin API. Server-authoritative, online-only (Phase 7).
/// Overridden in main with a [DioIamApi]; tests inject a fake.
final iamApiProvider = Provider<IamApi>(
    (ref) => throw UnimplementedError('override iamApiProvider in main'));

/// Staff list (server). Each mutation applies the server's answer to the list
/// instead of reloading it, so a change that succeeded never reads as failed on
/// a flaky connection.
class EmployeesController extends AsyncNotifier<List<EmployeeDto>> {
  IamApi get _api => ref.read(iamApiProvider);

  @override
  Future<List<EmployeeDto>> build() {
    ref.watch(sessionUserIdProvider);
    return _api.listEmployees();
  }

  void _apply(EmployeeDto e) {
    final list = state.asData?.value;
    if (list == null) {
      ref.invalidateSelf(); // not loaded yet: load it, without waiting
      return;
    }
    final i = list.indexWhere((x) => x.id == e.id);
    state = AsyncData(i < 0 ? [...list, e] : ([...list]..[i] = e));
  }

  Future<void> create({
    required String username,
    required String password,
    required String displayName,
    required String roleName,
  }) async =>
      _apply(await _api.createEmployee(
        username: username, password: password, displayName: displayName, roleName: roleName,
      ));

  Future<void> setStatus(String userId, {required bool active}) async =>
      _apply(await _api.setEmployeeStatus(userId, active: active));

  Future<void> assignRole(String userId, {required String branchId, required String roleName}) async =>
      _apply(await _api.assignRole(userId, branchId: branchId, roleName: roleName));

  Future<void> revokeAssignment(String userId, String branchId) async =>
      _apply(await _api.revokeAssignment(userId, branchId));

  Future<void> resetPassword(String userId, String newPassword) =>
      _api.resetPassword(userId, newPassword);
}

final employeesControllerProvider = AsyncNotifierProvider<EmployeesController, List<EmployeeDto>>(
  EmployeesController.new,
  retry: retryWhenOffline,
);

/// Branch list (server); mutations apply the server's answer, as above.
class BranchesController extends AsyncNotifier<List<BranchDto>> {
  IamApi get _api => ref.read(iamApiProvider);

  @override
  Future<List<BranchDto>> build() {
    ref.watch(sessionUserIdProvider);
    return _api.listBranches();
  }

  void _apply(BranchDto b) {
    final list = state.asData?.value;
    if (list == null) {
      ref.invalidateSelf();
      return;
    }
    final i = list.indexWhere((x) => x.id == b.id);
    state = AsyncData(i < 0 ? [...list, b] : ([...list]..[i] = b));
  }

  Future<void> create(String name) async => _apply(await _api.createBranch(name));

  Future<void> rename(String branchId, String name) async =>
      _apply(await _api.renameBranch(branchId, name));

  Future<void> setActive(String branchId, {required bool active}) async =>
      _apply(await _api.setBranchActive(branchId, active: active));
}

final branchesControllerProvider = AsyncNotifierProvider<BranchesController, List<BranchDto>>(
  BranchesController.new,
  retry: retryWhenOffline,
);
