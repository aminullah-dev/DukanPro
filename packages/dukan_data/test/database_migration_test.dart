import 'dart:convert';
import 'dart:io';

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
}
