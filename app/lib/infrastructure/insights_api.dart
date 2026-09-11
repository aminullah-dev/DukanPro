import 'package:dio/dio.dart';

import 'auth_api.dart' show AuthApiException, NetworkException;
import 'secure_store.dart';

/// Typed client for AI insights + the notification feed (Phase 9). Insights are
/// localizable codes + data; the client renders them per-locale.

class InsightDto {
  const InsightDto({
    required this.code,
    required this.severity,
    required this.data,
    this.entityType,
    this.entityId,
  });
  final String code;
  final String severity; // info | warning | critical
  final Map<String, Object?> data;
  final String? entityType;
  final String? entityId;

  factory InsightDto.fromJson(Map<String, dynamic> j) => InsightDto(
        code: j['code'] as String,
        severity: j['severity'] as String,
        data: ((j['data'] as Map?) ?? const {}).cast<String, Object?>(),
        entityType: j['entity_type'] as String?,
        entityId: j['entity_id'] as String?,
      );
}

class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.code,
    required this.severity,
    required this.data,
    required this.read,
    required this.createdAt,
  });
  final String id;
  final String code;
  final String severity;
  final Map<String, Object?> data;
  final bool read;
  final DateTime createdAt;

  factory NotificationDto.fromJson(Map<String, dynamic> j) => NotificationDto(
        id: j['id'] as String,
        code: j['code'] as String,
        severity: j['severity'] as String,
        data: ((j['data'] as Map?) ?? const {}).cast<String, Object?>(),
        read: (j['read'] as bool?) ?? false,
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      );
}

abstract interface class InsightsApi {
  Future<List<InsightDto>> listInsights();
  Future<List<NotificationDto>> listNotifications({bool unreadOnly = false});
  Future<int> refresh();
  Future<void> markRead(String id);
}

/// Dio-backed [InsightsApi] over the authoritative API. Reads the bearer token
/// fresh from secure storage; sends the active branch as `X-Branch-Id`.
class DioInsightsApi implements InsightsApi {
  DioInsightsApi({required String baseUrl, required this.store, this.branchId, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));
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

  @override
  Future<List<InsightDto>> listInsights() => _wrap(
        () async => _dio.get('/insights', options: await _opts()),
        (r) => ((r.data as Map)['insights'] as List)
            .map((e) => InsightDto.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<List<NotificationDto>> listNotifications({bool unreadOnly = false}) => _wrap(
        () async => _dio.get(
          '/notifications',
          queryParameters: {'unread_only': unreadOnly},
          options: await _opts(),
        ),
        (r) => ((r.data as Map)['notifications'] as List)
            .map((e) => NotificationDto.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<int> refresh() => _wrap(
        () async => _dio.post('/notifications/refresh', options: await _opts()),
        (r) => ((r.data as Map)['created'] as num).toInt(),
      );

  @override
  Future<void> markRead(String id) => _wrap(
        () async => _dio.patch('/notifications/$id/read', options: await _opts()),
        (_) {},
      );
}
