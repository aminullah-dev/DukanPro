import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

OutboxOp _op(int seq, String table, String rowId, Map<String, Object?> payload) => OutboxOp(
      opId: newId(), aggregateType: table, aggregateId: rowId, opType: 'insert', payload: payload,
      localSeq: seq, deviceId: 'd1', actorId: 'u1', createdAt: DateTime.utc(2026, 9, 12),
    );

Map<String, Object?> _saleMove(String productId, {String branch = 'B1'}) =>
    {'product_id': productId, 'branch_id': branch, 'qty_delta': -1, 'reason': 'sale'};

void main() {
  test('upgrading to v7 links pending legacy sale movements to their sale', () async {
    final dir = await Directory.systemTemp.createTemp('dukan_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.db');
    final s1 = newId();
    final s2 = newId();

    // A device on the old app: two sales whose stock movements carry no ref,
    // plus rows the upgrade must leave alone.
    final ops = [
      _op(1, 'sales', s1, {'number': 'INV-1', 'branch_id': 'B1'}),
      _op(2, 'stock_movements', newId(), _saleMove('p1')),
      _op(3, 'stock_movements', newId(),
          {'product_id': 'p1', 'branch_id': 'B1', 'qty_delta': 5, 'reason': 'adjustment'}),
      _op(4, 'sales', s2, {'number': 'INV-2', 'branch_id': 'B1'}),
      _op(5, 'stock_movements', newId(), _saleMove('p1')),
      _op(6, 'stock_movements', newId(), _saleMove('p2')),
      _op(7, 'stock_movements', newId(), _saleMove('p3')), // already sent
      _op(8, 'stock_movements', newId(), _saleMove('p4', branch: 'B2')), // not this sale's branch
    ];
    final old = AppDatabase(NativeDatabase(file));
    final oldOutbox = DriftSyncOutbox(old);
    for (final o in ops) {
      await oldOutbox.enqueue(o);
    }
    await oldOutbox.markAcked(ops[6].opId);
    await old.customStatement('PRAGMA user_version = 6');
    await old.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final pending = {for (final o in await DriftSyncOutbox(db).pending()) o.opId: o.payload};
    expect(pending[ops[1].opId], containsPair('ref_id', s1));
    expect(pending[ops[1].opId], containsPair('ref_type', 'sale'));
    expect(pending[ops[2].opId], isNot(contains('ref_id'))); // an adjustment has no sale
    expect(pending[ops[4].opId], containsPair('ref_id', s2));
    expect(pending[ops[5].opId], containsPair('ref_id', s2));
    expect(pending[ops[7].opId], isNot(contains('ref_id')));
    final sent = await (db.select(db.outboxEntries)..where((t) => t.id.equals(ops[6].opId))).getSingle();
    expect(jsonDecode(sent.payload), isNot(contains('ref_id')));
  });

  test('upgrading to v9 merges seeded copies of the built-in units into the fixed ones', () async {
    final dir = await Directory.systemTemp.createTemp('dukan_units');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.db');
    final kg = builtInUnits.firstWhere((u) => u.name == 'kg');
    final copy = newId(); // a "kg" this device seeded before the ids were fixed
    final rice = newId();
    final box = newId();

    final old = AppDatabase(NativeDatabase(file));
    await old.into(old.units).insert(UnitsCompanion.insert(id: copy, name: 'kg', decimalPlaces: const Value(3)));
    await old.into(old.units).insert(UnitsCompanion.insert(id: box, name: 'box', decimalPlaces: const Value(0)));
    await LocalCatalog(old).products.create(
        Product(id: rice, sku: 'RICE', name: 'Rice', unitId: copy, sellPrice: Money(8000, 'AFN')),
        barcodes: const []);
    final outbox = DriftSyncOutbox(old);
    final unitOp = _op(1, 'units', copy, {'name': 'kg', 'decimal_places': 3});
    final productOp = _op(2, 'products', rice, {'sku': 'RICE', 'name': 'Rice', 'unit_id': copy});
    await outbox.enqueue(unitOp);
    await outbox.enqueue(productOp);
    await old.customStatement('PRAGMA user_version = 8');
    await old.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final product = await (db.select(db.products)..where((t) => t.id.equals(rice))).getSingle();
    expect(product.unitId, kg.id);
    final live = await (db.select(db.units)..where((t) => t.deletedAt.isNull())).get();
    expect([for (final u in live) if (u.name == 'kg') u.id], [kg.id]);
    expect(live.map((u) => u.id), contains(box));
    final pending = {for (final o in await DriftSyncOutbox(db).pending()) o.opId: o.payload};
    expect(pending.containsKey(unitOp.opId), isFalse); // the copy's own insert is set aside
    expect(pending[productOp.opId], containsPair('unit_id', kg.id));
  });

  test('upgrading to v12 gives each sync cursor a token and a scope, keeping its position', () async {
    final dir = await Directory.systemTemp.createTemp('dukan_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.db');
    final old = AppDatabase(NativeDatabase(file));
    await old.into(old.syncStates).insert(SyncStatesCompanion.insert(deviceId: 'd1', lastPulledSeq: const Value(7)));
    await old.customStatement('ALTER TABLE sync_states DROP COLUMN watermark_token');
    await old.customStatement('ALTER TABLE sync_states DROP COLUMN scope');
    await old.customStatement('PRAGMA user_version = 11');
    await old.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final row = await (db.select(db.syncStates)..where((t) => t.deviceId.equals('d1'))).getSingle();
    expect((row.lastPulledSeq, row.watermarkToken, row.scope), (7, null, null));
  });

  test('upgrading to v13 gives sales a refund_of, keeping every sale', () async {
    final dir = await Directory.systemTemp.createTemp('dukan_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.db');
    final old = AppDatabase(NativeDatabase(file));
    final id = newId();
    await old.into(old.sales).insert(SalesCompanion.insert(id: id, number: 'INV-1', branchId: 'B1'));
    await old.customStatement('ALTER TABLE sales DROP COLUMN refund_of');
    await old.customStatement('PRAGMA user_version = 12');
    await old.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final sale = await (db.select(db.sales)..where((t) => t.id.equals(id))).getSingle();
    expect((sale.number, sale.refundOf), ('INV-1', null));
  });

  test('upgrading to v14 gives outbox ops a tx id, keeping every pending op', () async {
    final dir = await Directory.systemTemp.createTemp('dukan_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.db');
    final old = AppDatabase(NativeDatabase(file));
    await SyncRecorder(old).record(
      table: 'customers', rowId: newId(), op: 'insert', data: const {}, actorId: 'u1', deviceId: 'd1',
    );
    await old.customStatement('ALTER TABLE outbox_entries DROP COLUMN tx_id');
    await old.customStatement('PRAGMA user_version = 13');
    await old.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final ops = await DriftSyncOutbox(db).pending();
    expect((ops.length, ops.single.txId), (1, null));
  });
}
