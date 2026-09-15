import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart';

import '../database.dart';

/// Records one row-level op into the outbox per row written, carrying the full
/// row data (snake_case keys matching the server columns). This is the
/// sync-shaped representation the Phase 6 engine drains. See docs/sync-protocol.md.
final class SyncRecorder {
  SyncRecorder(this._db) : _outbox = DriftSyncOutbox(_db);
  final AppDatabase _db;
  final DriftSyncOutbox _outbox;

  Future<void> record({
    required String table,
    required String rowId,
    required String op, // insert | update
    required Map<String, Object?> data,
    int? baseVersion,
    required String actorId,
    required String deviceId,
  }) async {
    final maxCol = _db.outboxEntries.localSeq.max();
    final row = await (_db.selectOnly(_db.outboxEntries)..addColumns([maxCol])).getSingle();
    await _outbox.enqueue(OutboxOp(
      opId: newId(),
      aggregateType: table,
      aggregateId: rowId,
      opType: op,
      payload: data,
      localSeq: (row.read(maxCol) ?? 0) + 1,
      baseVersion: baseVersion,
      deviceId: deviceId,
      actorId: actorId,
      createdAt: DateTime.now().toUtc(),
      txId: currentOutboxTx(),
    ));
  }
}
