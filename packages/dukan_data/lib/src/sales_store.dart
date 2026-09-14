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
              qtyDelta: -l.qtyMinor, reason: 'sale', createdBy: Value(actorId),
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

  Future<void> _requireOpenShift(String shiftId, {required String branchId, required String userId}) async {
    final shift = await (_db.select(_db.shifts)..where((t) => t.id.equals(shiftId))).getSingleOrNull();
    if (shift == null || shift.status != 'open' || shift.branchId != branchId || shift.userId != userId) {
      throw ConflictError('SHIFT_NOT_OPEN', {'shift_id': shiftId});
    }
  }

  Future<List<SaleLineRow>> saleLinesFor(String saleId) =>
      (_db.select(_db.saleLines)..where((t) => t.saleId.equals(saleId))).get();

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
