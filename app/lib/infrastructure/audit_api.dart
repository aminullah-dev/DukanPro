import 'package:dio/dio.dart';

import 'auth_api.dart' show AuthApiException, NetworkException;
import 'http.dart' show newDio;
import 'secure_store.dart';

/// Typed client for the audit trail (Phase 10). Read-only; gated audit.view.

class AuditEntryDto {
  const AuditEntryDto({
    required this.id,
    required this.occurredAt,
    required this.action,
    this.actorId,
    this.actorName,
    this.entityType,
    this.entityId,
  });
  final String id;
  final DateTime occurredAt;
  final String action;
  final String? actorId;

  /// Who did it (their display name), when someone did.
  final String? actorName;
  final String? entityType;
  final String? entityId;

  factory AuditEntryDto.fromJson(Map<String, dynamic> j) => AuditEntryDto(
        id: j['id'] as String,
        occurredAt: DateTime.tryParse(j['occurred_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        action: j['action'] as String,
        actorId: j['actor_id'] as String?,
        actorName: j['actor_name'] as String?,
        entityType: j['entity_type'] as String?,
        entityId: j['entity_id'] as String?,
      );
}

abstract interface class AuditApi {
  Future<List<AuditEntryDto>> list({String? action, int limit = 100});
}

/// Dio-backed [AuditApi]. Bearer from secure storage; active branch header.
class DioAuditApi implements AuditApi {
  DioAuditApi({required String baseUrl, required this.store, this.branchId, Dio? dio})
      : _dio = dio ?? newDio(baseUrl);
  final Dio _dio;
  final SecureStore store;
  final String? branchId;

  Future<Options> _opts() async {
    final token = await store.read(SecureKeys.accessToken);
    return Options(headers: {
      if (token != null) 'authorization': 'Bearer $token',
      if (branchId != null) 'x-branch-id': branchId,
    });
  }

  @override
  Future<List<AuditEntryDto>> list({String? action, int limit = 100}) async {
    try {
      final qp = <String, Object?>{'limit': limit};
      if (action != null) qp['action'] = action;
      final r = await _dio.get('/audit', queryParameters: qp, options: await _opts());
      return ((r.data as Map)['entries'] as List)
          .map((e) => AuditEntryDto.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is Map) {
        final err = (data['error'] as Map).cast<String, dynamic>();
        throw AuthApiException((err['code'] as String?) ?? 'UNKNOWN', statusCode: e.response?.statusCode);
      }
      throw const NetworkException();
    }
  }
}
