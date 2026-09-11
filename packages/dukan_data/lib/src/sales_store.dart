import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart';

import '../database.dart';

/// Local, offline-first sales. Settling a cash sale writes the sale + lines +
/// payment + stock movements to SQLite AND enqueues outbox ops, in one
/// transaction (sync-shaped). See docs/domain/sales.md.
final class LocalSales {
  LocalSales(this._db) : _outbox = DriftSyncOutbox(_db);
  final AppDatabase _db;
  final DriftSyncOutbox _outbox;

  Future<SaleRow> settleCash({
    required List<SaleLine> lines,
    int discountMinor = 0,
    required int tenderedMinor,
    required String branchId,
    required String actorId,
    required String deviceId,
    String? shiftId,
  }) async {
    final currency = lines.isEmpty ? 'AFN' : lines.first.currency;
    final totals = computeTotals(lines, discountMinor: discountMinor);
    assertSettleable(
      lines: lines, totalMinor: totals.totalMinor, paidMinor: tenderedMinor,
      currency: currency, allowCredit: false,
    );
    final change = tenderedMinor - totals.totalMinor;
    final saleId = newId();
    final number = await _nextNumber();
    late SaleRow saved;

    await _db.transaction(() async {
      await _db.into(_db.sales).insert(SalesCompanion.insert(
            id: saleId, number: number, branchId: branchId,
            status: const Value('settled'), currency: Value(currency),
            discountMinor: Value(discountMinor), subtotalMinor: Value(totals.subtotalMinor),
            totalMinor: Value(totals.totalMinor), paidMinor: Value(totals.totalMinor),
            changeMinor: Value(change), shiftId: Value(shiftId),
            createdBy: Value(actorId), updatedBy: Value(actorId),
          ));
      for (final l in lines) {
        await _db.into(_db.saleLines).insert(SaleLinesCompanion.insert(
              id: newId(), saleId: saleId, productId: l.productId, name: l.name,
              qtyMinor: l.qtyMinor, decimalPlaces: Value(l.decimalPlaces),
              unitPriceMinor: l.unitPriceMinor, unitCostMinor: Value(l.unitCostMinor),
              lineTotalMinor: l.lineTotal, currency: Value(l.currency), createdBy: Value(actorId),
            ));
        final movementId = newId();
        await _db.into(_db.stockMovements).insert(StockMovementsCompanion.insert(
              id: movementId, productId: l.productId, branchId: branchId,
              qtyDelta: -l.qtyMinor, reason: 'sale', createdBy: Value(actorId),
            ));
        await _enqueue('stock_movement', movementId, 'append', {
          'product_id': l.productId, 'branch_id': branchId,
          'qty_delta': -l.qtyMinor, 'reason': 'sale',
        }, actorId, deviceId);
      }
      await _db.into(_db.payments).insert(PaymentsCompanion.insert(
            id: newId(), saleId: saleId, method: 'cash', amountMinor: totals.totalMinor,
            currency: Value(currency), tenderedMinor: Value(tenderedMinor),
            changeMinor: Value(change), createdBy: Value(actorId),
          ));
      await _enqueue('sale', saleId, 'settle', {
        'number': number, 'total_minor': totals.totalMinor,
        'lines': lines.map((l) => {'product_id': l.productId, 'qty_minor': l.qtyMinor}).toList(),
      }, actorId, deviceId);

      saved = await (_db.select(_db.sales)..where((t) => t.id.equals(saleId))).getSingle();
    });
    return saved;
  }

  Future<List<SaleLineRow>> saleLinesFor(String saleId) =>
      (_db.select(_db.saleLines)..where((t) => t.saleId.equals(saleId))).get();

  Future<String> _nextNumber() async {
    final countCol = _db.sales.id.count();
    final row = await (_db.selectOnly(_db.sales)..addColumns([countCol])).getSingle();
    final n = (row.read(countCol) ?? 0) + 1;
    final now = DateTime.now();
    String two(int x) => x.toString().padLeft(2, '0');
    return 'INV-${now.year}${two(now.month)}${two(now.day)}-${n.toString().padLeft(4, '0')}';
  }

  Future<void> _enqueue(
    String aggregateType,
    String aggregateId,
    String opType,
    Map<String, Object?> payload,
    String actorId,
    String deviceId,
  ) async {
    final maxCol = _db.outboxEntries.localSeq.max();
    final row = await (_db.selectOnly(_db.outboxEntries)..addColumns([maxCol])).getSingle();
    final nextSeq = (row.read(maxCol) ?? 0) + 1;
    await _outbox.enqueue(OutboxOp(
      opId: newId(), aggregateType: aggregateType, aggregateId: aggregateId, opType: opType,
      payload: payload, localSeq: nextSeq, deviceId: deviceId, actorId: actorId,
      createdAt: DateTime.now().toUtc(),
    ));
  }
}
