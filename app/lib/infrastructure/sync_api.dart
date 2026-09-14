import 'package:dio/dio.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_sync/dukan_sync.dart';

import 'auth_api.dart' show AuthApiException, NetworkException;
import 'http.dart' show errorCode, newDio;
import 'secure_store.dart';

/// [SyncClient] over the authoritative FastAPI sync API. Pushes row-level ops
/// and pulls the change feed; the bearer token is read fresh from secure
/// storage on each call. See docs/sync-protocol.md.
class DioSyncClient implements SyncClient {
  DioSyncClient({required String baseUrl, required this.store, Dio? dio})
      : _dio = dio ?? newDio(baseUrl);
  final Dio _dio;
  final SecureStore store;

  Future<Options> _auth() async {
    final token = await store.read(SecureKeys.accessToken);
    return Options(headers: {if (token != null) 'authorization': 'Bearer $token'});
  }

  @override
  Future<List<PushResult>> push(List<OutboxOp> ops) async {
    if (ops.isEmpty) return const [];
    try {
      final r = await _dio.post(
        '/sync/push',
        data: {
          'device_id': ops.first.deviceId,
          'ops': [
            for (final o in ops)
              {
                'op_id': o.opId,
                'table': o.aggregateType,
                'row_id': o.aggregateId,
                'op': o.opType,
                'data': o.payload,
                'base_version': o.baseVersion,
                // The server applies an op only under the token of the user who
                // recorded it; system seeds carry no actor and apply as the pusher.
                if (o.actorId != systemActorId) 'actor_id': o.actorId,
                'created_at': o.createdAt.toUtc().toIso8601String(),
              },
          ],
        },
        options: await _auth(),
      );
      final results = ((r.data as Map)['results'] as List).cast<Map<String, dynamic>>();
      return results.map(_toPushResult).toList(growable: false);
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<PullResult> pull({required int sinceWatermark}) async {
    try {
      final r = await _dio.get(
        '/sync/pull',
        queryParameters: {'since': sinceWatermark},
        options: await _auth(),
      );
      final data = (r.data as Map).cast<String, dynamic>();
      final changes = (data['changes'] as List).cast<Map<String, dynamic>>();
      return PullResult(
        watermark: (data['watermark'] as num).toInt(),
        maxSeq: (data['max_seq'] as num?)?.toInt(),
        changed: changes.map((c) => c.cast<String, Object?>()).toList(growable: false),
        tombstones: const [],
      );
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  /// A refusal the server explains is not "offline".
  Exception _failure(DioException e) => switch (errorCode(e)) {
        final code? => AuthApiException(code, statusCode: e.response?.statusCode),
        null => const NetworkException(),
      };

  PushResult _toPushResult(Map<String, dynamic> j) => PushResult(
        j['op_id'] as String,
        _outcome(j['outcome'] as String),
        version: (j['version'] as num?)?.toInt(),
        serverSeq: (j['server_seq'] as num?)?.toInt(),
        code: j['code'] as String?,
        current: (j['current'] as Map?)?.cast<String, Object?>(),
      );

  OpOutcome _outcome(String s) => switch (s) {
        'applied' => OpOutcome.applied,
        'conflict' => OpOutcome.conflict,
        _ => OpOutcome.rejected,
      };
}
