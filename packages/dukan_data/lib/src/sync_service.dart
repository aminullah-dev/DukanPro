import 'package:drift/drift.dart';
import 'package:dukan_sync/dukan_sync.dart';

import '../database.dart';

int _i(Object? v) => (v as num?)?.toInt() ?? 0;
int? _iN(Object? v) => (v as num?)?.toInt();
String _s(Object? v) => v as String? ?? '';
String? _sN(Object? v) => v as String?;
bool _b(Object? v, {bool fallback = false}) => v as bool? ?? fallback;

/// Drains the outbox to the server and applies server changes back — the
/// offline-first sync loop. See docs/sync-protocol.md.
final class SyncEngine {
  SyncEngine(this._db, this._client, {this.deviceId = 'app'});
  final AppDatabase _db;
  final SyncClient _client;
  final String deviceId;

  Future<void> syncNow() async {
    await pushPending();
    await pullSince();
  }

  Future<int> pendingCount() => _countByStatus('pending');

  Future<int> conflictCount() => _countByStatus('conflict');

  Future<int> _countByStatus(String status) async {
    final c = _db.outboxEntries.id.count();
    final row = await (_db.selectOnly(_db.outboxEntries)
          ..addColumns([c])
          ..where(_db.outboxEntries.status.equals(status)))
        .getSingle();
    return row.read(c) ?? 0;
  }

  Future<void> pushPending() async {
    final outbox = DriftSyncOutbox(_db);
    final pending = await outbox.pending();
    if (pending.isEmpty) return;
    final results = await _client.push(pending);
    for (final r in results) {
      switch (r.outcome) {
        case OpOutcome.applied:
          await outbox.markAcked(r.opId);
        case OpOutcome.conflict:
          await _setStatus(r.opId, 'conflict');
        case OpOutcome.rejected:
          await _setStatus(r.opId, 'rejected');
      }
    }
  }

  Future<void> pullSince() async {
    final since = await _lastPulled();
    final result = await _client.pull(sinceWatermark: since);
    await _db.transaction(() async {
      for (final change in result.changed) {
        await _apply(
          _s(change['table']),
          _s(change['row_id']),
          _s(change['op']),
          (change['data'] as Map).cast<String, Object?>(),
        );
      }
    });
    await _setLastPulled(result.watermark);
  }

  Future<int> _lastPulled() async {
    final row = await (_db.select(_db.syncStates)..where((t) => t.deviceId.equals(deviceId)))
        .getSingleOrNull();
    return row?.lastPulledSeq ?? 0;
  }

  Future<void> _setLastPulled(int seq) async {
    await _db.into(_db.syncStates).insertOnConflictUpdate(
          SyncStatesCompanion.insert(deviceId: deviceId, lastPulledSeq: Value(seq)),
        );
  }

  Future<void> _setStatus(String opId, String status) async {
    await (_db.update(_db.outboxEntries)..where((t) => t.id.equals(opId)))
        .write(OutboxEntriesCompanion(status: Value(status)));
  }

  Future<void> _apply(String table, String id, String op, Map<String, Object?> d) async {
    switch (table) {
      case 'products':
        if (op == 'update') {
          await (_db.update(_db.products)..where((t) => t.id.equals(id))).write(ProductsCompanion(
            name: Value(_s(d['name'])),
            sellPriceMinor: Value(_i(d['sell_price_minor'])),
            sellCurrency: Value(_s(d['sell_currency'])),
            isActive: Value(_b(d['is_active'], fallback: true)),
          ));
        } else {
          await _db.into(_db.products).insertOnConflictUpdate(ProductsCompanion.insert(
            id: id, sku: _s(d['sku']), name: _s(d['name']), unitId: _s(d['unit_id']),
            categoryId: Value(_sN(d['category_id'])),
            sellPriceMinor: Value(_i(d['sell_price_minor'])),
            sellCurrency: Value(_s(d['sell_currency'])),
            costMinor: Value(_iN(d['cost_minor'])), costCurrency: Value(_sN(d['cost_currency'])),
            trackStock: Value(_b(d['track_stock'], fallback: true)),
            isActive: Value(_b(d['is_active'], fallback: true)),
          ));
        }
      case 'barcodes':
        await _db.into(_db.barcodes).insertOnConflictUpdate(BarcodesCompanion.insert(
          id: id, productId: _s(d['product_id']), code: _s(d['code']),
          symbology: Value(_s(d['symbology'])),
        ));
      case 'units':
        await _db.into(_db.units).insertOnConflictUpdate(UnitsCompanion.insert(
          id: id, name: _s(d['name']), decimalPlaces: Value(_i(d['decimal_places'])),
        ));
      case 'stock_movements':
        await _db.into(_db.stockMovements).insertOnConflictUpdate(StockMovementsCompanion.insert(
          id: id, productId: _s(d['product_id']), branchId: _s(d['branch_id']),
          qtyDelta: _i(d['qty_delta']), reason: _s(d['reason']),
        ));
      case 'sales':
        await _db.into(_db.sales).insertOnConflictUpdate(SalesCompanion.insert(
          id: id, number: _s(d['number']), branchId: _s(d['branch_id']),
          shiftId: Value(_sN(d['shift_id'])), customerId: Value(_sN(d['customer_id'])),
          status: Value(_s(d['status'])), currency: Value(_s(d['currency'])),
          discountMinor: Value(_i(d['discount_minor'])), subtotalMinor: Value(_i(d['subtotal_minor'])),
          taxMinor: Value(_i(d['tax_minor'])), totalMinor: Value(_i(d['total_minor'])),
          paidMinor: Value(_i(d['paid_minor'])), changeMinor: Value(_i(d['change_minor'])),
        ));
      case 'sale_lines':
        await _db.into(_db.saleLines).insertOnConflictUpdate(SaleLinesCompanion.insert(
          id: id, saleId: _s(d['sale_id']), productId: _s(d['product_id']), name: _s(d['name']),
          qtyMinor: _i(d['qty_minor']), decimalPlaces: Value(_i(d['decimal_places'])),
          unitPriceMinor: _i(d['unit_price_minor']), unitCostMinor: Value(_i(d['unit_cost_minor'])),
          lineTotalMinor: _i(d['line_total_minor']), currency: Value(_s(d['currency'])),
        ));
      case 'payments':
        await _db.into(_db.payments).insertOnConflictUpdate(PaymentsCompanion.insert(
          id: id, saleId: _s(d['sale_id']), method: _s(d['method']), amountMinor: _i(d['amount_minor']),
          currency: Value(_s(d['currency'])), tenderedMinor: Value(_iN(d['tendered_minor'])),
          changeMinor: Value(_iN(d['change_minor'])),
        ));
      case 'customers':
        await _db.into(_db.customers).insertOnConflictUpdate(CustomersCompanion.insert(
          id: id, name: _s(d['name']), phone: Value(_sN(d['phone'])),
          creditLimitMinor: Value(_iN(d['credit_limit_minor'])), currency: Value(_s(d['currency'])),
          isActive: Value(_b(d['is_active'], fallback: true)),
        ));
      case 'customer_ledger':
        await _db.into(_db.customerLedger).insertOnConflictUpdate(CustomerLedgerCompanion.insert(
          id: id, customerId: _s(d['customer_id']), type: _s(d['type']),
          amountMinor: _i(d['amount_minor']), currency: Value(_s(d['currency'])),
          refType: Value(_sN(d['ref_type'])), refId: Value(_sN(d['ref_id'])),
        ));
      case 'suppliers':
        await _db.into(_db.suppliers).insertOnConflictUpdate(SuppliersCompanion.insert(
          id: id, name: _s(d['name']), phone: Value(_sN(d['phone'])), currency: Value(_s(d['currency'])),
          isActive: Value(_b(d['is_active'], fallback: true)),
        ));
      case 'supplier_ledger':
        await _db.into(_db.supplierLedger).insertOnConflictUpdate(SupplierLedgerCompanion.insert(
          id: id, supplierId: _s(d['supplier_id']), type: _s(d['type']),
          amountMinor: _i(d['amount_minor']), currency: Value(_s(d['currency'])),
        ));
    }
  }
}
