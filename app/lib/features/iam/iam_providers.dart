import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/iam_api.dart';
import '../auth/session.dart';

/// The employee/branch admin API. Server-authoritative, online-only (Phase 7).
/// Overridden in main with a [DioIamApi]; tests inject a fake.
final iamApiProvider = Provider<IamApi>(
    (ref) => throw UnimplementedError('override iamApiProvider in main'));

/// Staff list (server). Mutations go through [EmployeesController].
class EmployeesController extends AsyncNotifier<List<EmployeeDto>> {
  IamApi get _api => ref.read(iamApiProvider);

  @override
  Future<List<EmployeeDto>> build() {
    ref.watch(sessionUserIdProvider);
    return _api.listEmployees();
  }

  Future<void> _refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> create({
    required String username,
    required String password,
    required String displayName,
    required String roleName,
  }) async {
    await _api.createEmployee(
      username: username, password: password, displayName: displayName, roleName: roleName,
    );
    await _refresh();
  }

  Future<void> setStatus(String userId, {required bool active}) async {
    await _api.setEmployeeStatus(userId, active: active);
    await _refresh();
  }

  Future<void> assignRole(String userId, {required String branchId, required String roleName}) async {
    await _api.assignRole(userId, branchId: branchId, roleName: roleName);
    await _refresh();
  }

  Future<void> revokeAssignment(String userId, String branchId) async {
    await _api.revokeAssignment(userId, branchId);
    await _refresh();
  }

  Future<void> resetPassword(String userId, String newPassword) =>
      _api.resetPassword(userId, newPassword);
}

final employeesControllerProvider =
    AsyncNotifierProvider<EmployeesController, List<EmployeeDto>>(EmployeesController.new);

/// Branch list (server). Mutations go through [BranchesController].
class BranchesController extends AsyncNotifier<List<BranchDto>> {
  IamApi get _api => ref.read(iamApiProvider);

  @override
  Future<List<BranchDto>> build() {
    ref.watch(sessionUserIdProvider);
    return _api.listBranches();
  }

  Future<void> _refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> create(String name) async {
    await _api.createBranch(name);
    await _refresh();
  }

  Future<void> rename(String branchId, String name) async {
    await _api.renameBranch(branchId, name);
    await _refresh();
  }

  Future<void> setActive(String branchId, {required bool active}) async {
    await _api.setBranchActive(branchId, active: active);
    await _refresh();
  }
}

final branchesControllerProvider =
    AsyncNotifierProvider<BranchesController, List<BranchDto>>(BranchesController.new);
