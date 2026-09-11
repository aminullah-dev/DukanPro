import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:test/test.dart';

/// An in-memory stand-in for the authoritative FastAPI sync server. Mirrors
/// SqlSyncService: dedupe by opId, append-only insert-if-absent, master
/// upsert with optimistic `version` → conflict, and a monotonic change feed.
final class FakeSyncServer {
  static const _master = {'products', 'barcodes', 'customers', 'suppliers', 'units', 'categories'};

  final Map<String, PushResult> _processed = {}; // opId -> result (idempotency)
  final Map<String, int> _version = {}; // "table/id" -> current version
  final List<Map<String, Object?>> _log = []; // change feed, seq == index + 1

  List<PushResult> push(List<OutboxOp> ops) {
    final out = <PushResult>[];
    for (final op in ops) {
      final seen = _processed[op.opId];
      if (seen != null) {
        out.add(seen); // replay ⇒ same result, no duplicate applied
        continue;
      }
      final result = _apply(op);
      _processed[op.opId] = result;
      out.add(result);
    }
    return out;
  }

  PushResult _apply(OutboxOp op) {
    final key = '${op.aggregateType}/${op.aggregateId}';
    if (_master.contains(op.aggregateType)) {
      final current = _version[key];
      if (op.opType == 'update' && current != null && op.baseVersion != current) {
        return PushResult(op.opId, OpOutcome.conflict,
            code: '${op.aggregateType.toUpperCase()}_VERSION_CONFLICT');
      }
      final next = (current ?? 0) + 1;
      _version[key] = next;
      _appendLog(op);
      return PushResult(op.opId, OpOutcome.applied, version: next);
    }
    // append-only ledger: insert-if-absent, never conflicts.
    _appendLog(op);
    return PushResult(op.opId, OpOutcome.applied);
  }

  void _appendLog(OutboxOp op) {
    _log.add({
      'table': op.aggregateType,
      'row_id': op.aggregateId,
      'op': op.opType,
      'data': op.payload,
    });
  }

  PullResult pull(int since) {
    final changed = _log.sublist(since); // seq > since
    return PullResult(watermark: _log.length, changed: changed, tombstones: const []);
  }
}

/// A [SyncClient] over the in-process [FakeSyncServer].
final class FakeSyncClient implements SyncClient {
  FakeSyncClient(this._server);
  final FakeSyncServer _server;

  @override
  Future<List<PushResult>> push(List<OutboxOp> ops) async => _server.push(ops);

  @override
  Future<PullResult> pull({required int sinceWatermark}) async => _server.pull(sinceWatermark);
}

void main() {
  // The convergence test legitimately opens two independent in-memory DBs
  // (two devices), each with its own executor — not the race drift warns about.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('pushPending acks applied ops and marks conflicts', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final server = FakeSyncServer();
    final catalog = LocalCatalog(db);
    final engine = SyncEngine(db, FakeSyncClient(server), deviceId: 'd1');

    final p = Product(id: newId(), sku: 'A1', name: 'Rice', unitId: 'kg', sellPrice: Money(52000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'd1');
    expect(await engine.pendingCount(), 1);

    await engine.pushPending();
    expect(await engine.pendingCount(), 0); // applied ⇒ acked

    // A stale update (base_version 0 while the server is at 1) conflicts.
    await catalog.updateProduct(
      Product(id: p.id, sku: 'A1', name: 'Rice 2', unitId: 'kg', sellPrice: Money(60000, 'AFN')),
      actorId: 'u1', deviceId: 'd1',
    );
    await engine.pushPending();
    final conflicted = await (db.select(db.outboxEntries)
          ..where((t) => t.status.equals('conflict')))
        .get();
    expect(conflicted.length, 1);
    expect(conflicted.first.aggregateType, 'products');
  });

  test('pullSince upserts server rows locally and advances the watermark', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final server = FakeSyncServer();

    // Seed the server directly with a product the local DB has never seen.
    final pid = newId();
    server.push([
      OutboxOp(
        opId: newId(), aggregateType: 'products', aggregateId: pid, opType: 'insert',
        payload: {
          'sku': 'Z9', 'name': 'Sugar', 'unit_id': 'kg', 'category_id': null,
          'sell_price_minor': 30000, 'sell_currency': 'AFN', 'cost_minor': null,
          'cost_currency': null, 'track_stock': true, 'is_active': true,
        },
        localSeq: 1, deviceId: 'other', actorId: 'u2', createdAt: DateTime.now().toUtc(),
      ),
    ]);

    final engine = SyncEngine(db, FakeSyncClient(server), deviceId: 'd1');
    await engine.pullSince();

    final got = await LocalCatalog(db).products.findById(pid);
    expect(got?.name, 'Sugar');
    expect(got?.sellPrice, Money(30000, 'AFN'));

    // Watermark advanced ⇒ a second pull applies nothing new.
    await engine.pullSince();
    expect((await db.select(db.products).get()).length, 1);
  });

  test('two devices converge through one server', () async {
    final server = FakeSyncServer();

    final dbA = AppDatabase(NativeDatabase.memory());
    final dbB = AppDatabase(NativeDatabase.memory());
    addTearDown(dbA.close);
    addTearDown(dbB.close);

    final catA = LocalCatalog(dbA);
    final catB = LocalCatalog(dbB);
    final engA = SyncEngine(dbA, FakeSyncClient(server), deviceId: 'A');
    final engB = SyncEngine(dbB, FakeSyncClient(server), deviceId: 'B');

    final pA = Product(id: newId(), sku: 'A1', name: 'From A', unitId: 'kg', sellPrice: Money(1000, 'AFN'));
    final pB = Product(id: newId(), sku: 'B1', name: 'From B', unitId: 'kg', sellPrice: Money(2000, 'AFN'));
    await catA.createProduct(pA, actorId: 'uA', deviceId: 'A');
    await catB.createProduct(pB, actorId: 'uB', deviceId: 'B');

    // Each device pushes its own write, then pulls the other's.
    await engA.syncNow();
    await engB.syncNow();
    await engA.syncNow(); // A pulls B's product, now both have both

    for (final cat in [catA, catB]) {
      expect((await cat.products.findById(pA.id))?.name, 'From A');
      expect((await cat.products.findById(pB.id))?.name, 'From B');
    }

    // Re-running sync is a no-op (idempotent): no duplicate rows.
    await engA.syncNow();
    await engB.syncNow();
    expect((await dbA.select(dbA.products).get()).length, 2);
    expect((await dbB.select(dbB.products).get()).length, 2);
  });
}
