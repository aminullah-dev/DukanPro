import 'package:dio/dio.dart';

import 'http.dart' show newDio;

/// Typed client for the DukanPro auth API. DTOs mirror the server's JSON.

class ApiTokens {
  const ApiTokens({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
  factory ApiTokens.fromJson(Map<String, dynamic> j) =>
      ApiTokens(accessToken: j['access_token'] as String, refreshToken: j['refresh_token'] as String);
}

class BranchRoleDto {
  const BranchRoleDto({required this.branchId, required this.branchName, required this.roleName});
  final String branchId;
  final String branchName;
  final String roleName;
  factory BranchRoleDto.fromJson(Map<String, dynamic> j) => BranchRoleDto(
        branchId: j['branch_id'] as String,
        branchName: (j['branch_name'] as String?) ?? '',
        roleName: j['role_name'] as String,
      );
}

class ApiProfile {
  const ApiProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.branches,
    this.defaultBranchId,
  });
  final String id;
  final String username;
  final String displayName;
  final String? defaultBranchId;
  final List<BranchRoleDto> branches;
  factory ApiProfile.fromJson(Map<String, dynamic> j) => ApiProfile(
        id: j['id'] as String,
        username: j['username'] as String,
        displayName: j['display_name'] as String,
        defaultBranchId: j['default_branch_id'] as String?,
        branches: (j['branches'] as List)
            .map((e) => BranchRoleDto.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}

class ApiAuthResult {
  const ApiAuthResult({required this.user, required this.tokens});
  final ApiProfile user;
  final ApiTokens tokens;
  factory ApiAuthResult.fromJson(Map<String, dynamic> j) => ApiAuthResult(
        user: ApiProfile.fromJson((j['user'] as Map).cast<String, dynamic>()),
        tokens: ApiTokens.fromJson((j['tokens'] as Map).cast<String, dynamic>()),
      );
}

/// The server returned a structured error (e.g. INVALID_CREDENTIALS).
class AuthApiException implements Exception {
  const AuthApiException(this.code, {this.statusCode});
  final String code;
  final int? statusCode;
  @override
  String toString() => 'AuthApiException($code, $statusCode)';
}

/// Could not reach the server (the caller may fall back to offline unlock).
class NetworkException implements Exception {
  const NetworkException();
}

abstract interface class AuthApi {
  Future<ApiAuthResult> bootstrap({
    required String username,
    required String password,
    required String displayName,
    required String shopName,
    required String deviceId,
    required String setupToken,
  });
  Future<ApiAuthResult> login({
    required String username,
    required String password,
    required String deviceId,
  });
  Future<ApiTokens> refresh(String refreshToken);
  Future<void> logout(String refreshToken);
  Future<ApiProfile> me(String accessToken);
}

class DioAuthApi implements AuthApi {
  /// Sign-out has already wiped the device; the server only hears about it.
  static const _quick = Duration(seconds: 5);

  DioAuthApi({required String baseUrl, Dio? dio})
      : _dio = dio ?? newDio(baseUrl);
  final Dio _dio;

  Future<T> _wrap<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      final r = await call();
      return parse((r.data as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is Map) {
        final err = (data['error'] as Map).cast<String, dynamic>();
        throw AuthApiException((err['code'] as String?) ?? 'UNKNOWN', statusCode: e.response?.statusCode);
      }
      throw const NetworkException();
    }
  }

  @override
  Future<ApiAuthResult> bootstrap({
    required String username,
    required String password,
    required String displayName,
    required String shopName,
    required String deviceId,
    required String setupToken,
  }) =>
      _wrap(
        () => _dio.post('/auth/bootstrap', data: {
          'username': username,
          'password': password,
          'display_name': displayName,
          'shop_name': shopName,
          'device_id': deviceId,
          'setup_token': setupToken,
        }),
        ApiAuthResult.fromJson,
      );

  @override
  Future<ApiAuthResult> login({
    required String username,
    required String password,
    required String deviceId,
  }) =>
      _wrap(
        () => _dio.post('/auth/login', data: {
          'username': username,
          'password': password,
          'device_id': deviceId,
        }),
        ApiAuthResult.fromJson,
      );

  @override
  Future<ApiTokens> refresh(String refreshToken) => _wrap(
        () => _dio.post('/auth/refresh', data: {'refresh_token': refreshToken}),
        ApiTokens.fromJson,
      );

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        '/auth/logout',
        data: {'refresh_token': refreshToken},
        options: Options(sendTimeout: _quick, receiveTimeout: _quick),
      );
    } on DioException {
      // Best-effort; local credentials are cleared regardless.
    }
  }

  @override
  Future<ApiProfile> me(String accessToken) => _wrap(
        () => _dio.get('/auth/me', options: Options(headers: {'authorization': 'Bearer $accessToken'})),
        ApiProfile.fromJson,
      );
}
