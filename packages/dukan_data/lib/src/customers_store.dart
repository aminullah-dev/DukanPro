import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart';

import '../database.dart';
import 'sync_recorder.dart';

/// Local, offline-first customers & debt. Writes go to SQLite and enqueue
/// row-level outbox ops in one transaction.
final class LocalCustomers {
  LocalCustomers(this._db) : _rec = SyncRecorder(_db);
  final AppDatabase _db;
  final SyncRecorder _rec;

  Customer _toCustomer(CustomerRow r) => Customer(
        id: r.id, name: r.name, phone: r.phone, creditLimitMinor: r.creditLimitMinor,
        currency: r.currency, isActive: r.isActive, version: r.version,
      );

  Future<void> createCustomer(Customer c, {required String actorId, required String deviceId}) async {
    await _db.transaction(() async {
      await _db.into(_db.customers).insert(CustomersCompanion.insert(
            id: c.id, name: c.name, phone: Value(c.phone),
            creditLimitMinor: Value(c.creditLimitMinor), currency: Value(c.currency),
            createdBy: Value(actorId), updatedBy: Value(actorId),
          ));
      await _rec.record(table: 'customers', rowId: c.id, op: 'insert', data: {
        'name': c.name, 'phone': c.phone, 'credit_limit_minor': c.creditLimitMinor,
        'currency': c.currency, 'is_active': c.isActive,
      }, actorId: actorId, deviceId: deviceId);
    });
  }

  /// Change a customer's credit limit (null: no limit). A manager's decision:
  /// the screen offers it only with customer.credit, and the server checks again.
  Future<void> setCreditLimit(
    Customer c,
    int? creditLimitMinor, {
    required String actorId,
    required String deviceId,
  }) async {
    assertCreditLimitValid(creditLimitMinor: creditLimitMinor);
    await _db.transaction(() async {
      await (_db.update(_db.customers)..where((t) => t.id.equals(c.id))).write(CustomersCompanion(
            creditLimitMinor: Value(creditLimitMinor),
            updatedBy: Value(actorId),
            updatedAt: Value(DateTime.now().toUtc()),
          ));
      await _rec.record(
        table: 'customers', rowId: c.id, op: 'update', baseVersion: c.version,
        data: {'credit_limit_minor': creditLimitMinor}, actorId: actorId, deviceId: deviceId,
      );
    });
  }

  Future<List<Customer>> list({String? search}) async {
    final q = _db.select(_db.customers)..where((t) => t.deletedAt.isNull());
    if (search != null && search.isNotEmpty) {
      q.where((t) => t.name.like('%$search%'));
    }
    q.orderBy([(t) => OrderingTerm(expression: t.name)]);
    return (await q.get()).map(_toCustomer).toList();
  }

  Future<Customer?> find(String id) async {
    final r = await (_db.select(_db.customers)..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return r == null ? null : _toCustomer(r);
  }

  Future<List<CustomerLedgerEntry>> entries(String customerId) async {
    final rows = await (_db.select(_db.customerLedger)
          ..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.occurredAt)]))
        .get();
    return rows
        .map((r) => CustomerLedgerEntry(
              id: r.id, customerId: r.customerId, type: LedgerEntryType.values.byName(r.type),
              amountMinor: r.amountMinor, currency: r.currency, occurredAt: r.occurredAt,
              refType: r.refType, refId: r.refId,
            ))
        .toList();
  }

  Future<int> balance(String customerId) async => ledgerBalance(await entries(customerId));

  Future<void> recordPayment({
    required String customerId,
    required int amountMinor,
    String currency = 'AFN',
    required String actorId,
    required String deviceId,
  }) async {
    assertNotOverpaid(balanceMinor: await balance(customerId), paymentMinor: amountMinor);
    final ledgerId = newId();
    await _db.transaction(() async {
      await _db.into(_db.customerLedger).insert(CustomerLedgerCompanion.insert(
            id: ledgerId, customerId: customerId, type: 'payment', amountMinor: amountMinor,
            currency: Value(currency), refType: const Value('manual'), createdBy: Value(actorId),
          ));
      await _rec.record(table: 'customer_ledger', rowId: ledgerId, op: 'insert', data: {
        'customer_id': customerId, 'type': 'payment', 'amount_minor': amountMinor,
        'currency': currency, 'ref_type': 'manual',
      }, actorId: actorId, deviceId: deviceId);
    });
  }
}

/// Local, offline-first purchasing. A goods receipt increments stock at cost,
/// updates the product's last cost, and bills the supplier. Phase 6 syncs the
/// effects (stock movements + supplier bill); the receipt header stays local.
final class LocalPurchasing {
  LocalPurchasing(this._db) : _rec = SyncRecorder(_db);
  final AppDatabase _db;
  final SyncRecorder _rec;

  Supplier _toSupplier(SupplierRow r) => Supplier(
        id: r.id, name: r.name, phone: r.phone, currency: r.currency, isActive: r.isActive,
        version: r.version,
      );

  Future<void> createSupplier(Supplier s, {required String actorId, required String deviceId}) async {
    await _db.transaction(() async {
      await _db.into(_db.suppliers).insert(SuppliersCompanion.insert(
            id: s.id, name: s.name, phone: Value(s.phone), currency: Value(s.currency),
            createdBy: Value(actorId), updatedBy: Value(actorId),
          ));
      await _rec.record(table: 'suppliers', rowId: s.id, op: 'insert', data: {
        'name': s.name, 'phone': s.phone, 'currency': s.currency, 'is_active': s.isActive,
      }, actorId: actorId, deviceId: deviceId);
    });
  }

  Future<List<Supplier>> listSuppliers() async {
    final rows = await (_db.select(_db.suppliers)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
    return rows.map(_toSupplier).toList();
  }

  Future<int> supplierBalance(String supplierId) async {
    final rows = await (_db.select(_db.supplierLedger)
          ..where((t) => t.supplierId.equals(supplierId) & t.deletedAt.isNull()))
        .get();
    return rows.fold<int>(
      0, (sum, r) => sum + (r.type == 'payment' ? -r.amountMinor : r.amountMinor));
  }

  Future<void> receiveGoods({
    String? supplierId,
    required List<ReceiptLine> lines,
    required String branchId,
    required String actorId,
    required String deviceId,
  }) async {
    final total = lines.fold<int>(0, (s, l) => s + l.lineCost);
    await _db.transaction(() async {
      for (final l in lines) {
        final movementId = newId();
        await _db.into(_db.stockMovements).insert(StockMovementsCompanion.insert(
              id: movementId, productId: l.productId, branchId: branchId,
              qtyDelta: l.qtyMinor, reason: 'purchase', createdBy: Value(actorId),
            ));
        if (l.unitCostMinor > 0) {
          // A receipt without a cost (a stock keeper's) says nothing about the
          // price paid: the product keeps its cost, as on the server.
          await (_db.update(_db.products)..where((t) => t.id.equals(l.productId))).write(
            ProductsCompanion(
              costMinor: Value(l.unitCostMinor), costCurrency: const Value('AFN'),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
        }
        await _rec.record(table: 'stock_movements', rowId: movementId, op: 'insert', data: {
          'product_id': l.productId, 'branch_id': branchId, 'qty_delta': l.qtyMinor, 'reason': 'purchase',
        }, actorId: actorId, deviceId: deviceId);
      }
      // A zero-cost receipt owes the supplier nothing (and the server rejects a
      // zero bill), so it only moves stock.
      if (supplierId != null && total > 0) {
        final ledgerId = newId();
        await _db.into(_db.supplierLedger).insert(SupplierLedgerCompanion.insert(
              id: ledgerId, supplierId: supplierId, type: 'bill', amountMinor: total,
              createdBy: Value(actorId),
            ));
        await _rec.record(table: 'supplier_ledger', rowId: ledgerId, op: 'insert', data: {
          'supplier_id': supplierId, 'type': 'bill', 'amount_minor': total, 'currency': 'AFN',
        }, actorId: actorId, deviceId: deviceId);
      }
    });
  }
}
