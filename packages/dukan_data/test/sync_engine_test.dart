import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:test/test.dart';

/// One user's pull scope over the change feed: the payload they see for a
/// change, or null when the row is hidden from them.
typedef ChangeView = Map<String, Object?>? Function(Map<String, Object?> change);

/// An in-memory stand-in for the authoritative FastAPI sync server. Mirrors
/// SqlSyncService: dedupe by opId; append-only insert-if-absent; master rows by
/// compare-and-set on `version` (an update needs base_version, an insert on an
/// existing row conflicts); a monotonic change feed of post-images, paged by
/// [pageSize] with the watermark at the last row scanned.
final class FakeSyncServer {
  FakeSyncServer({this.pageSize = 500});
  static const _master = {'products', 'barcodes', 'customers', 'suppliers', 'units', 'categories'};

  final int pageSize;

  /// The server policy's verdict on an op: a code rejects it without recording
  /// it (the state-dependent outcomes the real server does not cache).
  String? Function(OutboxOp op)? rejectWith;

  final Map<String, PushResult> _processed = {}; // opId -> result (idempotency)
  final Map<String, Map<String, Object?>> _rows = {}; // "table/id" -> master row incl. version
  final List<Map<String, Object?>> _log = []; // change feed, seq == index + 1

  List<PushResult> push(List<OutboxOp> ops) {
    final out = <PushResult>[];
    for (final op in ops) {
      final seen = _processed[op.opId];
      if (seen != null) {
        out.add(seen); // replay ⇒ same result, no duplicate applied
        continue;
      }
      final code = rejectWith?.call(op);
      if (code != null) {
        out.add(PushResult(op.opId, OpOutcome.rejected, code: code));
        continue;
      }
      final result = _apply(op);
      _processed[op.opId] = result;
      out.add(result);
    }
    return out;
  }

  PushResult _apply(OutboxOp op) {
    final table = op.aggregateType;
    if (!_master.contains(table)) {
      // append-only ledger: insert-if-absent, never conflicts.
      log(table, op.aggregateId, op.opType, op.payload);
      return PushResult(op.opId, OpOutcome.applied, serverSeq: _log.length);
    }
    final key = '$table/${op.aggregateId}';
    final current = _rows[key];
    final prefix = table.toUpperCase();
    if (op.opType == 'insert') {
      if (current != null) {
        return PushResult(op.opId, OpOutcome.conflict, code: '${prefix}_ALREADY_EXISTS', current: current);
      }
      _rows[key] = {...op.payload, 'version': 1};
    } else {
      if (op.baseVersion == null) {
        return PushResult(op.opId, OpOutcome.rejected, code: 'SYNC_BASE_VERSION_REQUIRED');
      }
      if (current == null) {
        return PushResult(op.opId, OpOutcome.rejected, code: 'PRODUCT_NOT_FOUND'); // app updates products only
      }
      if (op.baseVersion != current['version']) {
        return PushResult(op.opId, OpOutcome.conflict, code: '${prefix}_VERSION_CONFLICT', current: current);
      }
      _rows[key] = {...current, ...op.payload, 'version': (current['version']! as int) + 1};
    }
    log(table, op.aggregateId, op.opType, _rows[key]!); // the post-image, not the payload
    return PushResult(op.opId, OpOutcome.applied, version: _rows[key]!['version']! as int, serverSeq: _log.length);
  }

  /// Appends a change_log row (a post-image), as an applied write would.
  void log(String table, String rowId, String op, Map<String, Object?> data) => _log.add(
        {'seq': _log.length + 1, 'table': table, 'row_id': rowId, 'op': op, 'data': data},
      );

  /// Up to [pageSize] rows after [since], seen through [view]; the watermark
  /// moves past hidden rows too.
  PullResult pull(int since, {ChangeView? view}) {
    final page = _log.skip(since).take(pageSize).toList();
    return PullResult(
      maxSeq: _log.length,
      watermark: page.isEmpty ? since : page.last['seq']! as int,
      changed: [for (final c in page) view == null ? c : view(c)].whereType<Map<String, Object?>>().toList(),
      tombstones: const [],
    );
  }
}

/// A [SyncClient] over the in-process [FakeSyncServer], pulling through [view]
/// (one user's scope). Records the ops it pushed and each pull's `since`.
final class FakeSyncClient implements SyncClient {
  FakeSyncClient(this._server, {this.view});
  final FakeSyncServer _server;
  final ChangeView? view;
  final List<OutboxOp> pushed = [];
  final List<int> pushBatches = [];
  final List<int> pulledSince = [];

  @override
  Future<List<PushResult>> push(List<OutboxOp> ops) async {
    pushed.addAll(ops);
    pushBatches.add(ops.length);
    return _server.push(ops);
  }

  @override
  Future<PullResult> pull({required int sinceWatermark}) async {
    pulledSince.add(sinceWatermark);
    return _server.pull(sinceWatermark, view: view);
  }
}

/// A cashier's pull scope (docs/sync-protocol.md, "Pull"): no supplier ledger,
/// and cost fields omitted.
Map<String, Object?>? _cashierView(Map<String, Object?> change) {
  if (change['table'] == 'supplier_ledger') return null;
  final data = Map<String, Object?>.of(change['data']! as Map<String, Object?>)
    ..remove('cost_minor')
    ..remove('cost_currency')
    ..remove('unit_cost_minor');
  return {...change, 'data': data};
}

OutboxOp _unitOp(int seq, String actorId) => OutboxOp(
      opId: newId(), aggregateType: 'units', aggregateId: newId(), opType: 'insert',
      payload: {'name': 'u$seq', 'decimal_places': 0}, localSeq: seq, deviceId: 'd1',
      actorId: actorId, createdAt: DateTime.now().toUtc(),
    );

Map<String, Object?> _product(String sku, {int? cost}) => {
      'sku': sku, 'name': 'Rice', 'unit_id': 'kg', 'category_id': null, 'sell_price_minor': 5000,
      'sell_currency': 'AFN', 'cost_minor': cost, 'cost_currency': cost == null ? null : 'AFN',
      'track_stock': true, 'is_active': true, 'version': 1,
    };

Product _renamed(Product p, String name) => Product(
      id: p.id, sku: p.sku, name: name, unitId: p.unitId, sellPrice: p.sellPrice, version: p.version,
    );

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

  test("pushPending sends only the signed-in user's ops plus system seeds", () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final client = FakeSyncClient(FakeSyncServer());
    final engine = SyncEngine(db, client, deviceId: 'd1');
    final outbox = DriftSyncOutbox(db);
    await outbox.enqueue(_unitOp(1, systemActorId));
    await outbox.enqueue(_unitOp(2, 'u1'));
    await outbox.enqueue(_unitOp(3, 'u2'));

    await engine.pushPending(actorId: 'u1');
    expect(client.pushed.map((o) => o.actorId), [systemActorId, 'u1']);
    expect(await engine.pendingCount(), 1); // u2's op waits for u2's own sync

    client.pushed.clear();
    await engine.pushPending(actorId: 'u2');
    expect(client.pushed.map((o) => o.actorId), ['u2']);
    expect(await engine.pendingCount(), 0);
  });

  test('terminal rejections are counted and never re-sent; state-dependent ones retry', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final server = FakeSyncServer();
    final client = FakeSyncClient(server);
    final engine = SyncEngine(db, client, deviceId: 'd1');
    final outbox = DriftSyncOutbox(db);
    final invalid = _unitOp(1, 'u1');
    final waiting = _unitOp(2, 'u1'); // its parent is still queued by another user
    final misrouted = _unitOp(3, 'u1'); // reached the server under another user's token
    for (final o in [invalid, waiting, misrouted]) {
      await outbox.enqueue(o);
    }
    final codes = {
      invalid.opId: 'SYNC_FIELD_INVALID',
      waiting.opId: 'PRODUCT_NOT_FOUND',
      misrouted.opId: 'SYNC_ACTOR_MISMATCH',
    };
    server.rejectWith = (op) => codes[op.opId];

    await engine.pushPending(actorId: 'u1');
    expect(await engine.rejectedCount(), 1);
    expect(await engine.pendingCount(), 2);

    // The server state changes (the parent arrives, the right user syncs): the
    // retried ops apply, and the terminal rejection is never re-sent.
    server.rejectWith = null;
    client.pushed.clear();
    await engine.pushPending(actorId: 'u1');
    expect(client.pushed.map((o) => o.opId), [waiting.opId, misrouted.opId]);
    expect(await engine.pendingCount(), 0);
    expect(await engine.rejectedCount(), 1);
  });

  test('each user pulls through their own cursor; omitted fields keep local values', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final server = FakeSyncServer();
    final owner = SyncEngine(db, FakeSyncClient(server), deviceId: 'd1');
    final cashier = SyncEngine(db, FakeSyncClient(server, view: _cashierView), deviceId: 'd1');

    // The cashier syncs first: the supplier bill is outside their scope and the
    // watermark moves past it. The owner's own cursor still delivers it.
    server.log('supplier_ledger', newId(), 'insert', {
      'supplier_id': newId(), 'type': 'bill', 'amount_minor': 7000, 'currency': 'AFN',
    });
    await cashier.pullSince(actorId: 'cashier');
    expect(await db.select(db.supplierLedger).get(), isEmpty);
    await owner.pullSince(actorId: 'owner');
    expect(await db.select(db.supplierLedger).get(), hasLength(1));

    // The owner pulls costs; the cashier's pull of the same rows omits them and
    // must not wipe them.
    final pid = newId();
    server
      ..log('products', pid, 'insert', _product('A1', cost: 700))
      ..log('sale_lines', newId(), 'insert', {
        'sale_id': newId(), 'product_id': pid, 'name': 'Rice', 'qty_minor': 1, 'decimal_places': 0,
        'unit_price_minor': 5000, 'unit_cost_minor': 700, 'line_total_minor': 5000, 'currency': 'AFN',
      });
    await owner.pullSince(actorId: 'owner');
    await cashier.pullSince(actorId: 'cashier');
    expect((await LocalCatalog(db).products.findById(pid))?.cost?.amountMinor, 700);
    expect((await db.select(db.saleLines).getSingle()).unitCostMinor, 700);

    // A price change's post-image carries the server's version for the next edit.
    server.log('products', pid, 'update', {..._product('A1'), 'sell_price_minor': 6000, 'version': 2});
    await cashier.pullSince(actorId: 'cashier');
    final got = await LocalCatalog(db).products.findById(pid);
    expect(got?.sellPrice, Money(6000, 'AFN'));
    expect(got?.version, 2);
  });

  test('pullSince pages until the watermark stops moving', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final server = FakeSyncServer(pageSize: 2);
    for (var i = 0; i < 5; i++) {
      server.log('units', newId(), 'insert', {'name': 'u$i', 'decimal_places': 0, 'version': 1});
    }
    final client = FakeSyncClient(server);

    await SyncEngine(db, client, deviceId: 'd1').pullSince(actorId: 'u1');

    expect(await db.select(db.units).get(), hasLength(5));
    expect(client.pulledSince, [0, 2, 4, 5]); // the last page is empty: caught up
  });

  test("a user's first cursor starts at the device-wide one", () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final server = FakeSyncServer()..log('units', newId(), 'insert', {'name': 'kg', 'decimal_places': 3});
    final client = FakeSyncClient(server);
    final engine = SyncEngine(db, client, deviceId: 'd1');

    await engine.pullSince(); // an unscoped pull, as before per-user cursors
    client.pulledSince.clear();
    await engine.pullSince(actorId: 'u1');

    expect(client.pulledSince, [1]); // nothing is pulled twice
  });

  test('pushPending sends the outbox in batches the server accepts', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final client = FakeSyncClient(FakeSyncServer());
    final outbox = DriftSyncOutbox(db);
    for (var i = 1; i <= 450; i++) {
      await outbox.enqueue(_unitOp(i, 'u1'));
    }

    await SyncEngine(db, client, deviceId: 'd1').pushPending(actorId: 'u1');

    expect(client.pushBatches, [200, 200, 50]);
    expect(client.pushed.map((o) => o.localSeq), List.generate(450, (i) => i + 1)); // in order
  });

  test("another user's pull never rewinds a product with edits not yet pushed", () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final engine = SyncEngine(db, FakeSyncClient(FakeSyncServer()), deviceId: 'd1');
    final catalog = LocalCatalog(db);
    final p = Product(id: newId(), sku: 'A1', name: 'Rice', unitId: 'kg', sellPrice: Money(1000, 'AFN'));
    await catalog.createProduct(p, actorId: 'uA', deviceId: 'd1');
    await engine.syncNow(actorId: 'uA');
    final synced = (await catalog.products.findById(p.id))!;
    await catalog.updateProduct(_renamed(synced, 'Rice 2'), actorId: 'uA', deviceId: 'd1');

    // User B's first pull on this device re-reads the product's insert image.
    await engine.pullSince(actorId: 'uB');
    final kept = (await catalog.products.findById(p.id))!;
    expect(kept.name, 'Rice 2');
    expect(kept.version, synced.version + 1);

    // So A's next edit sends the right base_version, and both edits apply.
    await catalog.updateProduct(_renamed(kept, 'Rice 3'), actorId: 'uA', deviceId: 'd1');
    await engine.pushPending(actorId: 'uA');
    expect(await engine.conflictCount(), 0);
    expect(await engine.pendingCount(), 0);
  });

  test("a stale edit takes the server's row and can be made again on top of it", () async {
    final server = FakeSyncServer();
    final dbA = AppDatabase(NativeDatabase.memory());
    final dbB = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await dbA.close();
      await dbB.close();
    });
    final a = SyncEngine(dbA, FakeSyncClient(server), deviceId: 'A');
    final b = SyncEngine(dbB, FakeSyncClient(server), deviceId: 'B');
    final catA = LocalCatalog(dbA);
    final catB = LocalCatalog(dbB);
    final p = Product(id: newId(), sku: 'T1', name: 'Tea', unitId: 'piece', sellPrice: Money(5000, 'AFN'));
    await catA.createProduct(p, actorId: 'u1', deviceId: 'A');
    await a.syncNow();
    await b.syncNow();

    Product priced(Product at, int price) => Product(
          id: at.id, sku: at.sku, name: at.name, unitId: at.unitId, sellPrice: Money(price, 'AFN'),
          version: at.version,
        );
    await catA.updateProduct(priced((await catA.products.findById(p.id))!, 6000), actorId: 'u1', deviceId: 'A');
    await catB.updateProduct(priced((await catB.products.findById(p.id))!, 4000), actorId: 'u1', deviceId: 'B');
    await a.syncNow();
    await b.pushPending();

    // B lost: its copy is the server's again, and its edit waits for review.
    expect((await catB.products.findById(p.id))!.sellPrice.amountMinor, 6000);
    final issues = await b.issues();
    expect((issues.single.status, issues.single.code, issues.single.canRetry),
        ('conflict', 'PRODUCTS_VERSION_CONFLICT', true));

    // Made again on top of the server's version, it applies and both devices agree.
    expect(await b.retry(issues.single.opId), isTrue);
    await b.syncNow();
    await a.syncNow();
    expect((await catA.products.findById(p.id))!.sellPrice.amountMinor, 4000);
    expect((await catB.products.findById(p.id))!.sellPrice.amountMinor, 4000);
    expect(await b.issues(), isEmpty);
    expect(await b.conflictCount(), 0);
  });

  test('a change the device cannot read is set aside and the pull goes on', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final server = FakeSyncServer()
      ..log('stock_movements', newId(), 'insert',
          {'product_id': 'p', 'branch_id': 'B1', 'qty_delta': 'five', 'reason': 'purchase'})
      ..log('units', newId(), 'insert', {'name': 'kg', 'decimal_places': 3, 'version': 1});
    final engine = SyncEngine(db, FakeSyncClient(server), deviceId: 'd1');
    await engine.pullSince();

    expect((await db.select(db.units).get()).map((u) => u.name), ['kg']);
    final kept = jsonDecode((await SettingsStore(db).get(SyncEngine.quarantineKey))!) as List;
    expect((kept.single as Map)['table'], 'stock_movements');
    final client = FakeSyncClient(server);
    await SyncEngine(db, client, deviceId: 'd1').pullSince();
    expect(client.pulledSince.first, 2); // past it: the next pull does not trip on it again
  });

  test('a server restored from a backup is read again from the start', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final before = FakeSyncServer();
    for (var i = 0; i < 3; i++) {
      before.log('units', newId(), 'insert', {'name': 'u$i', 'decimal_places': 0, 'version': 1});
    }
    await SyncEngine(db, FakeSyncClient(before), deviceId: 'd1').pullSince();
    final restored = FakeSyncServer()
      ..log('units', newId(), 'insert', {'name': 'box', 'decimal_places': 0, 'version': 1});
    await SyncEngine(db, FakeSyncClient(restored), deviceId: 'd1').pullSince();
    expect((await db.select(db.units).get()).map((u) => u.name), contains('box'));
  });

  test('pulled rows keep their time; customers keep their version and pending edits', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final at = DateTime.utc(2026, 9, 10, 8, 30);
    final saleId = newId();
    final customerId = newId();
    final server = FakeSyncServer()
      ..log('sales', saleId, 'insert', {
        'number': 'INV-1', 'branch_id': 'B1', 'status': 'settled', 'currency': 'AFN',
        'total_minor': 100, 'occurred_at': at.toIso8601String(),
      })
      ..log('customers', customerId, 'insert',
          {'name': 'Karim', 'credit_limit_minor': 0, 'currency': 'AFN', 'is_active': true, 'version': 1});
    final engine = SyncEngine(db, FakeSyncClient(server), deviceId: 'd1');
    await engine.pullSince();
    expect((await (db.select(db.sales)..where((t) => t.id.equals(saleId))).getSingle()).occurredAt.toUtc(), at);

    final customers = LocalCustomers(db);
    await customers.setCreditLimit((await customers.find(customerId))!, 500000, actorId: 'm1', deviceId: 'd1');
    server.log('customers', customerId, 'update',
        {'name': 'Karim', 'credit_limit_minor': 0, 'currency': 'AFN', 'is_active': true, 'version': 1});
    await engine.pullSince();
    final kept = (await customers.find(customerId))!;
    expect((kept.creditLimitMinor, kept.version), (500000, 2)); // the older image did not rewind it
  });
}
