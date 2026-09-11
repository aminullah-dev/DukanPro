import 'package:dio/dio.dart';

import 'auth_api.dart' show AuthApiException, BranchRoleDto, NetworkException;
import 'secure_store.dart';

/// Typed client for employee & branch administration. Server-authoritative and
/// online-only (Phase 7); DTOs mirror the server JSON. [BranchRoleDto] is
/// shared with the auth profile.

class EmployeeDto {
  const EmployeeDto({
    required this.id,
    required this.username,
    required this.displayName,
    required this.status,
    required this.branches,
    this.defaultBranchId,
  });
  final String id;
  final String username;
  final String displayName;
  final String status; // active | disabled
  final String? defaultBranchId;
  final List<BranchRoleDto> branches;

  bool get isActive => status == 'active';

  factory EmployeeDto.fromJson(Map<String, dynamic> j) => EmployeeDto(
        id: j['id'] as String,
        username: j['username'] as String,
        displayName: j['display_name'] as String,
        status: j['status'] as String,
        defaultBranchId: j['default_branch_id'] as String?,
        branches: (j['branches'] as List)
            .map((e) => BranchRoleDto.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}

class BranchDto {
  const BranchDto({
    required this.id,
    required this.name,
    required this.timezone,
    required this.currencyDefault,
    required this.isActive,
  });
  final String id;
  final String name;
  final String timezone;
  final String currencyDefault;
  final bool isActive;

  factory BranchDto.fromJson(Map<String, dynamic> j) => BranchDto(
        id: j['id'] as String,
        name: j['name'] as String,
        timezone: (j['timezone'] as String?) ?? 'Asia/Kabul',
        currencyDefault: (j['currency_default'] as String?) ?? 'AFN',
        isActive: (j['is_active'] as bool?) ?? true,
      );
}

abstract interface class IamApi {
  Future<List<EmployeeDto>> listEmployees();
  Future<EmployeeDto> createEmployee({
    required String username,
    required String password,
    required String displayName,
    required String roleName,
  });
  Future<EmployeeDto> setEmployeeStatus(String userId, {required bool active});
  Future<EmployeeDto> assignRole(String userId, {required String branchId, required String roleName});
  Future<EmployeeDto> revokeAssignment(String userId, String branchId);
  Future<void> resetPassword(String userId, String newPassword);

  Future<List<BranchDto>> listBranches();
  Future<BranchDto> createBranch(String name);
  Future<BranchDto> renameBranch(String branchId, String name);
  Future<BranchDto> setBranchActive(String branchId, {required bool active});
}

/// Dio-backed [IamApi]. Reads the bearer token fresh from secure storage and
/// sends the actor's active branch as `X-Branch-Id` on each call.
class DioIamApi implements IamApi {
  DioIamApi({required String baseUrl, required this.store, this.branchId, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));
  final Dio _dio;
  final SecureStore store;

  /// The actor's active branch, sent as `X-Branch-Id`. When null the server
  /// falls back to the actor's default branch.
  final String? branchId;

  Future<Options> _opts() async {
    final token = await store.read(SecureKeys.accessToken);
    return Options(headers: {
      if (token != null) 'authorization': 'Bearer $token',
      if (branchId != null) 'x-branch-id': branchId,
    });
  }

  Future<T> _wrap<T>(Future<Response<dynamic>> Function() call, T Function(Response<dynamic>) parse) async {
    try {
      return parse(await call());
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is Map) {
        final err = (data['error'] as Map).cast<String, dynamic>();
        throw AuthApiException((err['code'] as String?) ?? 'UNKNOWN', statusCode: e.response?.statusCode);
      }
      throw const NetworkException();
    }
  }

  List<T> _list<T>(Response<dynamic> r, String key, T Function(Map<String, dynamic>) parse) =>
      ((r.data as Map)[key] as List)
          .map((e) => parse((e as Map).cast<String, dynamic>()))
          .toList();

  EmployeeDto _employee(Response<dynamic> r) =>
      EmployeeDto.fromJson((r.data as Map).cast<String, dynamic>());
  BranchDto _branch(Response<dynamic> r) =>
      BranchDto.fromJson((r.data as Map).cast<String, dynamic>());

  @override
  Future<List<EmployeeDto>> listEmployees() => _wrap(
        () async => _dio.get('/users', options: await _opts()),
        (r) => _list(r, 'users', EmployeeDto.fromJson),
      );

  @override
  Future<EmployeeDto> createEmployee({
    required String username,
    required String password,
    required String displayName,
    required String roleName,
  }) =>
      _wrap(
        () async => _dio.post('/users', options: await _opts(), data: {
          'username': username,
          'password': password,
          'display_name': displayName,
          'role_name': roleName,
        }),
        _employee,
      );

  @override
  Future<EmployeeDto> setEmployeeStatus(String userId, {required bool active}) => _wrap(
        () async => _dio.patch('/users/$userId/status', options: await _opts(), data: {'active': active}),
        _employee,
      );

  @override
  Future<EmployeeDto> assignRole(String userId, {required String branchId, required String roleName}) =>
      _wrap(
        () async => _dio.post('/users/$userId/roles', options: await _opts(), data: {
          'branch_id': branchId,
          'role_name': roleName,
        }),
        _employee,
      );

  @override
  Future<EmployeeDto> revokeAssignment(String userId, String branchId) => _wrap(
        () async => _dio.delete('/users/$userId/roles/$branchId', options: await _opts()),
        _employee,
      );

  @override
  Future<void> resetPassword(String userId, String newPassword) => _wrap(
        () async => _dio.post('/users/$userId/password', options: await _opts(), data: {
          'new_password': newPassword,
        }),
        (_) {},
      );

  @override
  Future<List<BranchDto>> listBranches() => _wrap(
        () async => _dio.get('/branches', options: await _opts()),
        (r) => _list(r, 'branches', BranchDto.fromJson),
      );

  @override
  Future<BranchDto> createBranch(String name) => _wrap(
        () async => _dio.post('/branches', options: await _opts(), data: {'name': name}),
        _branch,
      );

  @override
  Future<BranchDto> renameBranch(String branchId, String name) => _wrap(
        () async => _dio.patch('/branches/$branchId', options: await _opts(), data: {'name': name}),
        _branch,
      );

  @override
  Future<BranchDto> setBranchActive(String branchId, {required bool active}) => _wrap(
        () async => _dio.patch('/branches/$branchId', options: await _opts(), data: {'active': active}),
        _branch,
      );
}
