import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart';

import '../database.dart';
import 'sync_recorder.dart';

/// Local, offline-first sales. Settling writes the sale + lines + payment +
/// stock movements (+ a customer-ledger charge for credit) to SQLite AND
/// enqueues one row-level outbox op per row, all in one transaction.
/// See docs/domain/sales.md and docs/sync-protocol.md.
final class LocalSales {
  LocalSales(this._db) : _rec = SyncRecorder(_db);
  final AppDatabase _db;
  final SyncRecorder _rec;

  /// Cash-only settle (no customer): one cash tender with what was handed over,
  /// toward the total (less than the total is `SALE_UNDERPAID`).
  Future<SaleRow> settleCash({
    required List<SaleLine> lines,
    int discountMinor = 0,
    required int tenderedMinor,
    required String branchId,
    required String actorId,
    required String deviceId,
    String? shiftId,
  }) {
    final total = computeTotals(lines, discountMinor: discountMinor).totalMinor;
    final paid = tenderedMinor < total ? tenderedMinor : total;
    return settle(
      lines: lines, discountMinor: discountMinor,
      tenders: [if (paid > 0) Tender(PaymentMethod.cash, paid, tenderedMinor: tenderedMinor)],
      branchId: branchId, actorId: actorId, deviceId: deviceId, shiftId: shiftId,
    );
  }

  /// General settle. [tenders] are the payments taken now: cash (with what was
  /// handed over), card or transfer, one or several. With a [customerId] the
  /// rest of the total posts to the customer ledger: the customer must be
  /// active, owe in the sale's currency and stay within their credit limit.
  /// With a [shiftId] the sale goes into that shift's drawer: the seller's own
  /// open shift in this branch (`SHIFT_NOT_OPEN`).
  Future<SaleRow> settle({
    required List<SaleLine> lines,
    int discountMinor = 0,
    required List<Tender> tenders,
    String? customerId,
    required String branchId,
    required String actorId,
    required String deviceId,
    String? shiftId,
  }) async {
    final currency = lines.isEmpty ? 'AFN' : lines.first.currency;
    assertSaleLinesValid(lines, currency: currency);
    final totals = computeTotals(lines, discountMinor: discountMinor);
    assertDiscountValid(discountMinor: discountMinor, subtotalMinor: totals.subtotalMinor);
    for (final t in tenders) {
      assertPaymentValid(method: t.method, amountMinor: t.amountMinor, tenderedMinor: t.tenderedMinor);
    }
    final paid = tenders.fold<int>(0, (sum, t) => sum + t.amountMinor);
    assertSettleable(
      lines: lines, totalMinor: totals.totalMinor, paidMinor: paid, currency: currency,
      allowCredit: customerId != null,
    );
    assertSaleNotOverpaid(paidMinor: paid, totalMinor: totals.totalMinor);
    // Change is cash handed back over a cash tender.
    final change = tenders.fold<int>(0, (sum, t) => sum + (t.tenderedMinor ?? t.amountMinor) - t.amountMinor);
    final remainder = totals.totalMinor - paid;
    final creditId = customerId;
    if (creditId != null && remainder > 0) {
      // The customer's own row decides, not what the screen showed.
      final customer = await (_db.select(_db.customers)
            ..where((t) => t.id.equals(creditId) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (customer == null) throw NotFoundError('CUSTOMER_NOT_FOUND', {'customer_id': creditId});
      assertCustomerCanBuyOnCredit(
        isActive: customer.isActive, customerCurrency: customer.currency, saleCurrency: currency,
      );
      assertWithinCreditLimit(
        balanceMinor: await _customerBalance(creditId),
        chargeMinor: remainder, creditLimitMinor: customer.creditLimitMinor,
      );
    }
    if (shiftId != null) await _requireOpenShift(shiftId, branchId: branchId, userId: actorId);
    await _requireStock(lines, branchId: branchId);
    final saleId = newId();
    late SaleRow saved;

    await _db.transaction(() async {
      final number = await _nextNumber(deviceId);
      await _db.into(_db.sales).insert(SalesCompanion.insert(
            id: saleId, number: number, branchId: branchId, customerId: Value(customerId),
            status: const Value('settled'), currency: Value(currency),
            discountMinor: Value(discountMinor), subtotalMinor: Value(totals.subtotalMinor),
            totalMinor: Value(totals.totalMinor), paidMinor: Value(paid), changeMinor: Value(change),
            shiftId: Value(shiftId), createdBy: Value(actorId), updatedBy: Value(actorId),
          ));
      await _rec.record(table: 'sales', rowId: saleId, op: 'insert', data: {
        'number': number, 'branch_id': branchId, 'shift_id': shiftId, 'customer_id': customerId,
        'status': 'settled', 'currency': currency, 'discount_minor': discountMinor,
        'subtotal_minor': totals.subtotalMinor, 'tax_minor': totals.taxMinor,
        'total_minor': totals.totalMinor, 'paid_minor': paid, 'change_minor': change,
      }, actorId: actorId, deviceId: deviceId);

      for (final l in lines) {
        final lineId = newId();
        await _db.into(_db.saleLines).insert(SaleLinesCompanion.insert(
              id: lineId, saleId: saleId, productId: l.productId, name: l.name,
              qtyMinor: l.qtyMinor, decimalPlaces: Value(l.decimalPlaces),
              unitPriceMinor: l.unitPriceMinor, unitCostMinor: Value(l.unitCostMinor),
              lineTotalMinor: l.lineTotal, currency: Value(l.currency), createdBy: Value(actorId),
            ));
        await _rec.record(table: 'sale_lines', rowId: lineId, op: 'insert', data: {
          'sale_id': saleId, 'product_id': l.productId, 'name': l.name, 'qty_minor': l.qtyMinor,
          'decimal_places': l.decimalPlaces, 'unit_price_minor': l.unitPriceMinor,
          'unit_cost_minor': l.unitCostMinor, 'line_total_minor': l.lineTotal, 'currency': l.currency,
        }, actorId: actorId, deviceId: deviceId);

        if (!l.trackStock) continue; // an untracked product (a service) moves no stock
        final movementId = newId();
        await _db.into(_db.stockMovements).insert(StockMovementsCompanion.insert(
              id: movementId, productId: l.productId, branchId: branchId,
              qtyDelta: -l.qtyMinor, reason: 'sale', refType: const Value('sale'),
              refId: Value(saleId), createdBy: Value(actorId),
            ));
        await _rec.record(table: 'stock_movements', rowId: movementId, op: 'insert', data: {
          'product_id': l.productId, 'branch_id': branchId, 'qty_delta': -l.qtyMinor, 'reason': 'sale',
          // The server accepts a sale movement only against the sale it belongs to.
          'ref_type': 'sale', 'ref_id': saleId,
        }, actorId: actorId, deviceId: deviceId);
      }
      for (final t in tenders) {
        final paymentId = newId();
        final tenderChange = t.tenderedMinor == null ? null : t.tenderedMinor! - t.amountMinor;
        await _db.into(_db.payments).insert(PaymentsCompanion.insert(
              id: paymentId, saleId: saleId, method: t.method.name, amountMinor: t.amountMinor,
              currency: Value(currency), tenderedMinor: Value(t.tenderedMinor),
              changeMinor: Value(tenderChange), createdBy: Value(actorId),
            ));
        await _rec.record(table: 'payments', rowId: paymentId, op: 'insert', data: {
          'sale_id': saleId, 'method': t.method.name, 'amount_minor': t.amountMinor,
          'currency': currency, 'tendered_minor': t.tenderedMinor, 'change_minor': tenderChange,
        }, actorId: actorId, deviceId: deviceId);
      }
      if (creditId != null && remainder > 0) {
        final ledgerId = newId();
        await _db.into(_db.customerLedger).insert(CustomerLedgerCompanion.insert(
              id: ledgerId, customerId: creditId, type: 'charge', amountMinor: remainder,
              currency: Value(currency), refType: const Value('sale'), refId: Value(saleId),
              createdBy: Value(actorId),
            ));
        await _rec.record(table: 'customer_ledger', rowId: ledgerId, op: 'insert', data: {
          'customer_id': customerId, 'type': 'charge', 'amount_minor': remainder, 'currency': currency,
          'ref_type': 'sale', 'ref_id': saleId,
        }, actorId: actorId, deviceId: deviceId);
      }

      saved = await (_db.select(_db.sales)..where((t) => t.id.equals(saleId))).getSingle();
    });
    return saved;
  }

  /// Voids a sale on this till, with or without a connection: the stock the sale
  /// took comes back and what the customer still owes for it comes off, all in
  /// one transaction. The server checks it when the rows arrive
  /// (docs/domain/sales.md).
  Future<void> voidSale({
    required String saleId,
    required String reason,
    required String actorId,
    required String deviceId,
  }) async {
    final why = reason.trim();
    if (why.isEmpty) throw ValidationError('SALE_VOID_REASON_REQUIRED');
    final sale = await byId(saleId);
    if (sale == null) throw NotFoundError('SALE_NOT_FOUND', {'sale_id': saleId});
    if (sale.status != 'settled' || sale.refundOf != null || (await returnsOf(saleId)).isNotEmpty) {
      throw ConflictError('SALE_NOT_VOIDABLE', {'status': sale.status});
    }
    // Cash counted in a closed drawer does not come back out of it: that is a return.
    final shiftId = sale.shiftId;
    if (shiftId != null && await _cashTaken(saleId) > 0) {
      final shift = await (_db.select(_db.shifts)..where((t) => t.id.equals(shiftId))).getSingleOrNull();
      if (shift != null && shift.status != 'open') {
        throw ConflictError('SALE_SHIFT_CLOSED', {'shift_id': shiftId});
      }
    }
    await _db.transaction(() async {
      await (_db.update(_db.sales)..where((t) => t.id.equals(saleId))).write(SalesCompanion(
            status: const Value('voided'), updatedBy: Value(actorId),
            updatedAt: Value(DateTime.now().toUtc()),
          ));
      await _rec.record(
        table: 'sales', rowId: saleId, op: 'update', baseVersion: 0,
        data: {'status': 'voided', 'void_reason': why}, actorId: actorId, deviceId: deviceId,
      );
      for (final movement in await _saleMovements(saleId)) {
        await _returnStock(
          productId: movement.productId, branchId: movement.branchId, qty: -movement.qtyDelta,
          refType: 'void', refId: saleId, actorId: actorId, deviceId: deviceId,
        );
      }
      await _reverseDebt(
        sale: sale, refType: 'void', refId: saleId, actorId: actorId, deviceId: deviceId,
      );
    });
  }

  /// Takes goods back from a settled sale, with or without a connection: a new
  /// sale with negative amounts that names it ([lines] is how much of each
  /// product comes back). What the customer still owes for the sale comes off
  /// first; the rest goes back by [method], cash out of [shiftId]'s drawer.
  Future<SaleRow> refund({
    required String saleId,
    required Map<String, int> lines,
    required String reason,
    required String method,
    String? shiftId,
    required String actorId,
    required String deviceId,
  }) async {
    final why = reason.trim();
    final sale = await byId(saleId);
    if (sale == null) throw NotFoundError('SALE_NOT_FOUND', {'sale_id': saleId});
    if (sale.status != 'settled' || sale.refundOf != null) {
      throw ConflictError('SALE_NOT_REFUNDABLE', {'status': sale.status});
    }
    if (!_refundMethods.contains(method)) {
      throw ValidationError('REFUND_METHOD_INVALID', {'method': method});
    }
    final wanted = {for (final e in lines.entries) if (e.value != 0) e.key: e.value};
    assertRefundValid(reason: why, wanted: wanted, returnable: await returnable(saleId));

    final sold = <String, int>{};
    final value = <String, int>{};
    final source = <String, SaleLineRow>{};
    for (final line in await saleLinesFor(saleId)) {
      sold[line.productId] = (sold[line.productId] ?? 0) + line.qtyMinor;
      value[line.productId] = (value[line.productId] ?? 0) + line.lineTotalMinor;
      source.putIfAbsent(line.productId, () => line);
    }
    final worth = {
      for (final e in wanted.entries)
        e.key: returnedValueMinor(
          lineTotalMinor: value[e.key] ?? 0, soldQtyMinor: sold[e.key] ?? 0, returnedQtyMinor: e.value,
        ),
    };
    final gross = worth.values.fold<int>(0, (sum, v) => sum + v);
    final earlier = (await returnsOf(saleId)).fold<int>(0, (sum, r) => sum + r.totalMinor);
    final left = sale.totalMinor + earlier; // what is still to give back
    final everything = (await returnable(saleId)).entries.every((e) => (wanted[e.key] ?? 0) == e.value);
    var total = everything
        ? left
        : refundTotalMinor(
            grossMinor: gross, saleSubtotalMinor: sale.subtotalMinor,
            saleDiscountMinor: sale.discountMinor,
          );
    if (total > left) total = left;
    final debtBack = await _debtToReverse(sale, upTo: total);
    final moneyBack = total - debtBack;
    if (method == 'cash' && moneyBack > 0) {
      if (shiftId == null) throw ConflictError('SHIFT_NOT_OPEN', {'shift_id': null});
      await _requireOpenShift(shiftId, branchId: sale.branchId, userId: actorId);
    }
    final refundId = newId();
    late SaleRow saved;
    await _db.transaction(() async {
      final number = await _nextNumber(deviceId);
      await _db.into(_db.sales).insert(SalesCompanion.insert(
            id: refundId, number: number, branchId: sale.branchId,
            customerId: Value(sale.customerId), status: const Value('settled'),
            currency: Value(sale.currency), discountMinor: Value(gross - total),
            subtotalMinor: Value(-gross), totalMinor: Value(-total), paidMinor: Value(-moneyBack),
            changeMinor: const Value(0), shiftId: Value(shiftId), refundOf: Value(saleId),
            createdBy: Value(actorId), updatedBy: Value(actorId),
          ));
      await _rec.record(table: 'sales', rowId: refundId, op: 'insert', data: {
        'number': number, 'branch_id': sale.branchId, 'shift_id': shiftId,
        'customer_id': sale.customerId, 'status': 'settled', 'currency': sale.currency,
        'discount_minor': gross - total, 'subtotal_minor': -gross, 'tax_minor': 0,
        'total_minor': -total, 'paid_minor': -moneyBack, 'change_minor': 0,
        'refund_of': saleId, 'refund_reason': why,
      }, actorId: actorId, deviceId: deviceId);

      for (final entry in wanted.entries) {
        final line = source[entry.key]!;
        final lineId = newId();
        await _db.into(_db.saleLines).insert(SaleLinesCompanion.insert(
              id: lineId, saleId: refundId, productId: entry.key, name: line.name,
              qtyMinor: -entry.value, decimalPlaces: Value(line.decimalPlaces),
              unitPriceMinor: line.unitPriceMinor, unitCostMinor: Value(line.unitCostMinor),
              lineTotalMinor: -worth[entry.key]!, currency: Value(sale.currency),
              createdBy: Value(actorId),
            ));
        await _rec.record(table: 'sale_lines', rowId: lineId, op: 'insert', data: {
          'sale_id': refundId, 'product_id': entry.key, 'name': line.name,
          'qty_minor': -entry.value, 'decimal_places': line.decimalPlaces,
          'unit_price_minor': line.unitPriceMinor, 'unit_cost_minor': line.unitCostMinor,
          'line_total_minor': -worth[entry.key]!, 'currency': sale.currency,
        }, actorId: actorId, deviceId: deviceId);
      }
      // Goods come back to stock only where the sale took them from it.
      final took = {for (final m in await _saleMovements(saleId)) m.productId: m.branchId};
      for (final entry in wanted.entries) {
        final branchId = took[entry.key];
        if (branchId == null) continue;
        await _returnStock(
          productId: entry.key, branchId: branchId, qty: entry.value, refType: 'refund',
          refId: refundId, actorId: actorId, deviceId: deviceId,
        );
      }
      if (moneyBack > 0) {
        final paymentId = newId();
        await _db.into(_db.payments).insert(PaymentsCompanion.insert(
              id: paymentId, saleId: refundId, method: method, amountMinor: -moneyBack,
              currency: Value(sale.currency), createdBy: Value(actorId),
            ));
        await _rec.record(table: 'payments', rowId: paymentId, op: 'insert', data: {
          'sale_id': refundId, 'method': method, 'amount_minor': -moneyBack,
          'currency': sale.currency, 'tendered_minor': null, 'change_minor': null,
        }, actorId: actorId, deviceId: deviceId);
      }
      if (debtBack > 0) {
        await _writeDebtReversal(
          sale: sale, amount: debtBack, refType: 'refund', refId: refundId, actorId: actorId,
          deviceId: deviceId,
        );
      }
      saved = await (_db.select(_db.sales)..where((t) => t.id.equals(refundId))).getSingle();
    });
    return saved;
  }

  static const _refundMethods = {'cash', 'card', 'transfer'};

  Future<int> _cashTaken(String saleId) async {
    final rows = await (_db.select(_db.payments)
          ..where((t) => t.saleId.equals(saleId) & t.deletedAt.isNull()))
        .get();
    return rows
        .where((p) => p.method == PaymentMethod.cash.name)
        .fold<int>(0, (sum, p) => sum + p.amountMinor);
  }

  /// The stock this sale took, as this device recorded it.
  Future<List<StockMovementRow>> _saleMovements(String saleId) => (_db.select(_db.stockMovements)
        ..where((t) => t.refType.equals('sale') & t.refId.equals(saleId) & t.deletedAt.isNull()))
      .get();

  Future<void> _returnStock({
    required String productId,
    required String branchId,
    required int qty,
    required String refType,
    required String refId,
    required String actorId,
    required String deviceId,
  }) async {
    final id = newId();
    await _db.into(_db.stockMovements).insert(StockMovementsCompanion.insert(
          id: id, productId: productId, branchId: branchId, qtyDelta: qty, reason: 'returned',
          refType: Value(refType), refId: Value(refId), createdBy: Value(actorId),
        ));
    await _rec.record(table: 'stock_movements', rowId: id, op: 'insert', data: {
      'product_id': productId, 'branch_id': branchId, 'qty_delta': qty, 'reason': 'returned',
      'ref_type': refType, 'ref_id': refId,
    }, actorId: actorId, deviceId: deviceId);
  }

  /// What a void or a return takes off the customer: what the sale charged, less
  /// what earlier ones took back, and never more than the customer still owes
  /// (money they paid is handed back instead) or than [upTo].
  Future<int> _debtToReverse(SaleRow sale, {int? upTo}) async {
    final customerId = sale.customerId;
    if (customerId == null) return 0;
    final charges = await (_db.select(_db.customerLedger)
          ..where((t) =>
              t.type.equals('charge') & t.refType.equals('sale') & t.refId.equals(sale.id) & t.deletedAt.isNull()))
        .get();
    final charged = charges.fold<int>(0, (sum, c) => sum + c.amountMinor);
    if (charged <= 0) return 0;
    final refunds = [for (final r in await returnsOf(sale.id)) r.id];
    final reversals = await (_db.select(_db.customerLedger)
          ..where((t) =>
              t.type.equals('adjustment') &
              ((t.refType.equals('void') & t.refId.equals(sale.id)) |
                  (t.refType.equals('refund') & t.refId.isIn(refunds))) &
              t.deletedAt.isNull()))
        .get();
    final reversed = reversals.fold<int>(0, (sum, r) => sum - r.amountMinor);
    var back = charged - reversed;
    if (upTo != null && upTo < back) back = upTo;
    final owed = await _customerBalance(customerId);
    if (owed < back) back = owed;
    return back > 0 ? back : 0;
  }

  Future<void> _reverseDebt({
    required SaleRow sale,
    required String refType,
    required String refId,
    required String actorId,
    required String deviceId,
  }) async {
    final back = await _debtToReverse(sale);
    if (back <= 0) return;
    await _writeDebtReversal(
      sale: sale, amount: back, refType: refType, refId: refId, actorId: actorId,
      deviceId: deviceId,
    );
  }

  Future<void> _writeDebtReversal({
    required SaleRow sale,
    required int amount,
    required String refType,
    required String refId,
    required String actorId,
    required String deviceId,
  }) async {
    final customerId = sale.customerId!;
    final id = newId();
    await _db.into(_db.customerLedger).insert(CustomerLedgerCompanion.insert(
          id: id, customerId: customerId, type: 'adjustment', amountMinor: -amount,
          currency: Value(sale.currency), refType: Value(refType), refId: Value(refId),
          createdBy: Value(actorId),
        ));
    await _rec.record(table: 'customer_ledger', rowId: id, op: 'insert', data: {
      'customer_id': customerId, 'type': 'adjustment', 'amount_minor': -amount,
      'currency': sale.currency, 'ref_type': refType, 'ref_id': refId,
    }, actorId: actorId, deviceId: deviceId);
  }

  /// A single till sells no more of a stock-tracked product than it holds, as
  /// far as it knows (docs/sync-protocol.md: two offline tills can still oversell
  /// together, which the server flags). `STOCK_INSUFFICIENT` names the SKU.
  Future<void> _requireStock(List<SaleLine> lines, {required String branchId}) async {
    final wanted = <String, int>{};
    for (final l in lines) {
      if (l.trackStock) wanted[l.productId] = (wanted[l.productId] ?? 0) + l.qtyMinor;
    }
    for (final MapEntry(key: productId, value: qty) in wanted.entries) {
      final sum = _db.stockMovements.qtyDelta.sum();
      final row = await (_db.selectOnly(_db.stockMovements)
            ..addColumns([sum])
            ..where(_db.stockMovements.productId.equals(productId) &
                _db.stockMovements.branchId.equals(branchId) &
                _db.stockMovements.deletedAt.isNull()))
          .getSingle();
      final available = row.read(sum) ?? 0;
      if (qty > available) {
        final product = await (_db.select(_db.products)..where((t) => t.id.equals(productId))).getSingleOrNull();
        throw ConflictError('STOCK_INSUFFICIENT', {'sku': product?.sku, 'requested': qty, 'available': available});
      }
    }
  }

  Future<void> _requireOpenShift(String shiftId, {required String branchId, required String userId}) async {
    final shift = await (_db.select(_db.shifts)..where((t) => t.id.equals(shiftId))).getSingleOrNull();
    if (shift == null || shift.status != 'open' || shift.branchId != branchId || shift.userId != userId) {
      throw ConflictError('SHIFT_NOT_OPEN', {'shift_id': shiftId});
    }
  }

  /// The latest sales on this device in [branchId], newest first: to reprint a
  /// receipt.
  Future<List<SaleRow>> recent({required String branchId, int limit = 30}) => (_db.select(_db.sales)
        ..where((t) => t.branchId.equals(branchId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
        ..limit(limit))
      .get();

  Future<List<SaleLineRow>> saleLinesFor(String saleId) =>
      (_db.select(_db.saleLines)..where((t) => t.saleId.equals(saleId))).get();

  /// The sale with [id], such as the one a return takes goods back from.
  Future<SaleRow?> byId(String id) => (_db.select(_db.sales)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// The returns this device knows of for [saleId]: sales that name it in refund_of.
  Future<List<SaleRow>> returnsOf(String saleId) => (_db.select(_db.sales)
        ..where((t) => t.refundOf.equals(saleId) & t.deletedAt.isNull()))
      .get();

  /// What of each product [saleId] can still take back: what it sold, less what
  /// its returns took back (their lines are negative).
  Future<Map<String, int>> returnable(String saleId) async {
    final ids = [saleId, for (final r in await returnsOf(saleId)) r.id];
    final lines = await (_db.select(_db.saleLines)
          ..where((t) => t.saleId.isIn(ids) & t.deletedAt.isNull()))
        .get();
    final left = <String, int>{};
    for (final line in lines) {
      left[line.productId] = (left[line.productId] ?? 0) + line.qtyMinor;
    }
    return left;
  }

  Future<int> _customerBalance(String customerId) async {
    final rows = await (_db.select(_db.customerLedger)
          ..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull()))
        .get();
    final entries = rows.map((r) => CustomerLedgerEntry(
          id: r.id, customerId: r.customerId, type: LedgerEntryType.values.byName(r.type),
          amountMinor: r.amountMinor, currency: r.currency, occurredAt: r.occurredAt,
        ));
    return ledgerBalance(entries);
  }

  /// A sale number no other device can issue: `INV-<device>-<local date>-<n>`.
  /// Counted inside the settle transaction, so two settles on one till never
  /// share one either.
  Future<String> _nextNumber(String deviceId) async {
    final now = DateTime.now();
    String two(int x) => x.toString().padLeft(2, '0');
    final device = deviceId.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    final tag = (device.length > 6 ? device.substring(device.length - 6) : device).toUpperCase();
    final prefix = 'INV-$tag-${now.year}${two(now.month)}${two(now.day)}-';
    final countCol = _db.sales.id.count();
    final row = await (_db.selectOnly(_db.sales)
          ..addColumns([countCol])
          ..where(_db.sales.number.like('$prefix%')))
        .getSingle();
    final n = (row.read(countCol) ?? 0) + 1;
    return '$prefix${n.toString().padLeft(4, '0')}';
  }
}
