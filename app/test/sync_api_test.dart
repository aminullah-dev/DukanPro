import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:dukanpro/infrastructure/sync_api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Captures the request and answers like POST /sync/push (every op rejected).
class _PushAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final ops = ((options.data as Map)['ops'] as List).cast<Map<String, Object?>>();
    return ResponseBody.fromString(
      jsonEncode({
        'results': [
          for (final o in ops)
            {'op_id': o['op_id'], 'outcome': 'rejected', 'server_seq': null, 'code': 'SYNC_FIELD_INVALID'},
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

OutboxOp _unitOp(String actorId) => OutboxOp(
      opId: newId(), aggregateType: 'units', aggregateId: newId(), opType: 'insert',
      payload: const {'name': 'kg', 'decimal_places': 3}, localSeq: 1, deviceId: 'd1',
      actorId: actorId, createdAt: DateTime.utc(2026, 9, 12, 8),
    );

void main() {
  test('push sends who recorded each op and when; system seeds carry no actor', () async {
    final adapter = _PushAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://sync.test'))..httpClientAdapter = adapter;
    final client = DioSyncClient(baseUrl: 'http://sync.test', store: FakeSecureStore(), dio: dio);

    final results = await client.push([_unitOp('u1'), _unitOp(systemActorId)]);

    final sent = ((adapter.request!.data as Map)['ops'] as List).cast<Map<String, Object?>>();
    expect(sent[0]['actor_id'], 'u1');
    expect(sent[0]['created_at'], '2026-09-12T08:00:00.000Z');
    expect(sent[1].containsKey('actor_id'), isFalse);
    expect(results.map((r) => r.code), ['SYNC_FIELD_INVALID', 'SYNC_FIELD_INVALID']);
    expect(results.every((r) => r.outcome == OpOutcome.rejected), isTrue);
  });
}
