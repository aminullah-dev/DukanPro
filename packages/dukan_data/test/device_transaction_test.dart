// The ops one local transaction records share a tx id (a nested transaction
// keeps it), and a push never ends inside one: the server applies its ledger
// rows together (docs/sync-protocol.md).
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:test/test.dart';

final class _CountingClient implements SyncClient {
  final batches = <List<OutboxOp>>[];

  @override
  Future<List<PushResult>> push(List<OutboxOp> ops) async {
    batches.add(ops);
    return [for (final o in ops) PushResult(o.opId, OpOutcome.applied)];
  }

  @override
  Future<PullResult> pull({required int sinceWatermark, String? sinceToken}) =>
      throw UnimplementedError('pushes only');
}

void main() {
  late AppDatabase db;
  late SyncRecorder rec;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    rec = SyncRecorder(db);
  });
  tearDown(() => db.close());

  Future<void> record(String table) =>
      rec.record(table: table, rowId: newId(), op: 'insert', data: const {}, actorId: 'u1', deviceId: 'd1');

  test('the ops one transaction records share a tx id; a nested one keeps it', () async {
    await db.transaction(() async {
      await record('sales');
      await record('sale_lines');
      await db.transaction(() => record('payments'));
    });
    await db.transaction(() => record('sales'));
    await record('customers');
    final tx = [for (final o in await DriftSyncOutbox(db).pending()) o.txId];
    expect(tx[0], isNotNull);
    expect(tx.sublist(0, 3).toSet(), {tx[0]});
    expect(tx[3], allOf(isNotNull, isNot(tx[0])));
    expect(tx[4], isNull);
  });

  test('a push ends at its batch size, but never inside a transaction', () async {
    await db.transaction(() async {
      for (final table in ['sales', 'sale_lines', 'sale_lines', 'payments']) {
        await record(table);
      }
    });
    await record('customers');
    await record('customers');
    final client = _CountingClient();
    await SyncEngine(db, client, deviceId: 'd1', pushBatch: 2).pushPending();
    expect(client.batches.map((b) => b.length), [4, 2]);
    expect(await DriftSyncOutbox(db).pending(), isEmpty);
  });
}
