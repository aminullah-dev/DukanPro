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
            // The next edit chains on this one; a pull of an older image leaves it.
            version: Value(c.version + 1),
          ));
      await _rec.record(
        table: 'customers', rowId: c.id, op: 'update', baseVersion: c.version,
        data: {'credit_limit_minor': creditLimitMinor}, actorId: actorId, deviceId: deviceId,
      );
    });
  }

  /// Close a customer's account to credit, or reopen it: a manager's decision,
  /// offered with customer.credit and checked again by the server.
  Future<void> setActive(
    Customer c,
    bool isActive, {
    required String actorId,
    required String deviceId,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.customers)..where((t) => t.id.equals(c.id))).write(CustomersCompanion(
            isActive: Value(isActive),
            updatedBy: Value(actorId),
            updatedAt: Value(DateTime.now().toUtc()),
            version: Value(c.version + 1),
          ));
      await _rec.record(
        table: 'customers', rowId: c.id, op: 'update', baseVersion: c.version,
        data: {'is_active': isActive}, actorId: actorId, deviceId: deviceId,
      );
    });
  }

  /// Forgive part or all of what a customer owes: a negative adjustment on the
  /// append-only ledger, never more than the balance. Offered with
  /// debt.write_off; the server checks again.
  Future<void> writeOff({
    required Customer customer,
    required int amountMinor,
    required String actorId,
    required String deviceId,
  }) async {
    assertWriteOffValid(amountMinor: amountMinor, balanceMinor: await balance(customer.id));
    final ledgerId = newId();
    await _db.transaction(() async {
      await _db.into(_db.customerLedger).insert(CustomerLedgerCompanion.insert(
            id: ledgerId, customerId: customer.id, type: 'adjustment', amountMinor: -amountMinor,
            currency: Value(customer.currency), refType: const Value('write_off'),
            createdBy: Value(actorId),
          ));
      await _rec.record(table: 'customer_ledger', rowId: ledgerId, op: 'insert', data: {
        'customer_id': customer.id, 'type': 'adjustment', 'amount_minor': -amountMinor,
        'currency': customer.currency, 'ref_type': 'write_off',
      }, actorId: actorId, deviceId: deviceId);
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

  /// A debt payment, by [method]. With a [shiftId] (the till's open shift),
  /// cash collected counts in that shift's drawer.
  Future<void> recordPayment({
    required String customerId,
    required int amountMinor,
    String currency = 'AFN',
    PaymentMethod method = PaymentMethod.cash,
    String? shiftId,
    required String actorId,
    required String deviceId,
  }) async {
    assertDebtPaymentValid(amountMinor: amountMinor);
    assertPaymentValid(method: method, amountMinor: amountMinor);
    assertNotOverpaid(balanceMinor: await balance(customerId), paymentMinor: amountMinor);
    final ledgerId = newId();
    await _db.transaction(() async {
      await _db.into(_db.customerLedger).insert(CustomerLedgerCompanion.insert(
            id: ledgerId, customerId: customerId, type: 'payment', amountMinor: amountMinor,
            currency: Value(currency), refType: const Value('manual'), method: Value(method.name),
            shiftId: Value(shiftId), createdBy: Value(actorId),
          ));
      await _rec.record(table: 'customer_ledger', rowId: ledgerId, op: 'insert', data: {
        'customer_id': customerId, 'type': 'payment', 'amount_minor': amountMinor,
        'currency': currency, 'ref_type': 'manual', 'method': method.name, 'shift_id': shiftId,
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

  /// Pays a supplier what the shop owes them: never more (`SUPPLIER_OVERPAYMENT`),
  /// in their currency. With a [shiftId] (the till's open shift), cash comes out
  /// of that shift's drawer.
  Future<void> paySupplier({
    required Supplier supplier,
    required int amountMinor,
    PaymentMethod method = PaymentMethod.cash,
    String? shiftId,
    required String actorId,
    required String deviceId,
  }) async {
    assertSupplierPaymentValid(amountMinor: amountMinor, balanceMinor: await supplierBalance(supplier.id));
    assertPaymentValid(method: method, amountMinor: amountMinor);
    final ledgerId = newId();
    await _db.transaction(() async {
      await _db.into(_db.supplierLedger).insert(SupplierLedgerCompanion.insert(
            id: ledgerId, supplierId: supplier.id, type: 'payment', amountMinor: amountMinor,
            currency: Value(supplier.currency), method: Value(method.name), shiftId: Value(shiftId),
            createdBy: Value(actorId),
          ));
      await _rec.record(table: 'supplier_ledger', rowId: ledgerId, op: 'insert', data: {
        'supplier_id': supplier.id, 'type': 'payment', 'amount_minor': amountMinor,
        'currency': supplier.currency, 'method': method.name, 'shift_id': shiftId,
      }, actorId: actorId, deviceId: deviceId);
    });
  }

  /// A received cost is a versioned product edit, so it reaches the server and
  /// every other device, in the product's selling currency.
  Future<void> _recordCost(ReceiptLine l, {required String actorId, required String deviceId}) async {
    final p = await (_db.select(_db.products)..where((t) => t.id.equals(l.productId))).getSingleOrNull();
    if (p == null || p.costMinor == l.unitCostMinor) return;
    await (_db.update(_db.products)..where((t) => t.id.equals(p.id))).write(ProductsCompanion(
      costMinor: Value(l.unitCostMinor), costCurrency: Value(p.sellCurrency),
      updatedAt: Value(DateTime.now().toUtc()), version: Value(p.version + 1),
    ));
    await _rec.record(
      table: 'products', rowId: p.id, op: 'update', baseVersion: p.version,
      data: {'cost_minor': l.unitCostMinor}, actorId: actorId, deviceId: deviceId,
    );
  }

  Future<void> receiveGoods({
    String? supplierId,
    required List<ReceiptLine> lines,
    required String branchId,
    required String actorId,
    required String deviceId,
  }) async {
    lines.forEach(assertReceivable);
    final total = receiptTotal(lines);
    await _db.transaction(() async {
      for (final l in lines) {
        // A receipt without a cost (a stock keeper's) says nothing about the price
        // paid: the product keeps its cost, as on the server.
        if (l.unitCostMinor > 0) await _recordCost(l, actorId: actorId, deviceId: deviceId);
        final product = await (_db.select(_db.products)..where((t) => t.id.equals(l.productId))).getSingleOrNull();
        // An untracked product (a service) is billed and costed but moves no stock.
        if (product != null && !product.trackStock) continue;
        final movementId = newId();
        await _db.into(_db.stockMovements).insert(StockMovementsCompanion.insert(
              id: movementId, productId: l.productId, branchId: branchId,
              qtyDelta: l.qtyMinor, reason: 'purchase', createdBy: Value(actorId),
            ));
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
