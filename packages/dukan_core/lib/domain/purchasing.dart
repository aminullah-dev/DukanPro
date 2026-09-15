/// Purchasing domain. Mirrors docs/domain/purchasing.md and
/// server/dukan/domain/purchasing.py. Phase 4 uses a direct goods receipt
/// (no full PO lifecycle): receiving increments stock at cost and bills the
/// supplier. The supplier balance is derived from an append-only ledger.
library;

import '../shared/errors.dart';
import 'numbers.dart' show moneyMax;
import 'sales.dart' show lineTotalFits, lineTotalMinor;

enum SupplierEntryType { bill, payment, adjustment }

final class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    this.phone,
    this.currency = 'AFN',
    this.isActive = true,
    this.version = 0,
  });

  final String id;
  final String name;
  final String? phone;
  final String currency;
  final bool isActive;
  final int version;
}

final class SupplierLedgerEntry {
  const SupplierLedgerEntry({
    required this.id,
    required this.supplierId,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.occurredAt,
  });

  final String id;
  final String supplierId;
  final SupplierEntryType type;
  final int amountMinor;
  final String currency;
  final DateTime occurredAt;

  /// Bills add (shop owes), payments subtract.
  int get signed => switch (type) {
        SupplierEntryType.bill => amountMinor,
        SupplierEntryType.adjustment => amountMinor,
        SupplierEntryType.payment => -amountMinor,
      };
}

int supplierBalance(Iterable<SupplierLedgerEntry> entries) =>
    entries.fold(0, (sum, e) => sum + e.signed);

/// One line of a goods receipt: [qtyMinor] in the unit's minor granularity
/// (10^[decimalPlaces]) at [unitCostMinor] per whole unit.
final class ReceiptLine {
  const ReceiptLine({
    required this.productId,
    required this.qtyMinor,
    required this.unitCostMinor,
    required this.decimalPlaces,
  });
  final String productId;
  final int qtyMinor;
  final int unitCostMinor;
  final int decimalPlaces;

  /// Quantity × cost at the unit's scale, ROUND_HALF_UP like a sale line: 2.500
  /// kg at 40.00 is 100.00.
  int get lineCost => lineTotalMinor(unitCostMinor, qtyMinor, decimalPlaces);
}

/// A received line adds a positive quantity at a cost of zero or more (zero: a
/// quantity-only receipt), costing at most [moneyMax]. Raises [ValidationError]
/// `GRN_LINE_INVALID` or `GRN_TOTAL_TOO_LARGE`.
void assertReceivable(ReceiptLine line) {
  if (line.qtyMinor <= 0 || line.unitCostMinor < 0) {
    throw ValidationError('GRN_LINE_INVALID', {
      'product_id': line.productId, 'qty': line.qtyMinor, 'cost': line.unitCostMinor,
    });
  }
  if (!lineTotalFits(line.unitCostMinor, line.qtyMinor, line.decimalPlaces)) {
    throw ValidationError('GRN_TOTAL_TOO_LARGE', {'product_id': line.productId});
  }
}

/// What a receipt of valid lines bills: their costs, at most [moneyMax].
/// Raises [ValidationError] `GRN_TOTAL_TOO_LARGE`.
int receiptTotal(Iterable<ReceiptLine> lines) {
  var total = 0;
  for (final l in lines) {
    total += l.lineCost; // each at most moneyMax, so the sum cannot wrap first
    if (total > moneyMax) throw ValidationError('GRN_TOTAL_TOO_LARGE', {});
  }
  return total;
}

/// A payment to a supplier is a positive amount, no more than the shop owes
/// them. Raises [ValidationError] `SUPPLIER_PAYMENT_INVALID` or [ConflictError]
/// `SUPPLIER_OVERPAYMENT`.
void assertSupplierPaymentValid({required int amountMinor, required int balanceMinor}) {
  if (amountMinor <= 0) throw ValidationError('SUPPLIER_PAYMENT_INVALID', {'amount': amountMinor});
  if (amountMinor > balanceMinor) {
    throw ConflictError('SUPPLIER_OVERPAYMENT', {'amount': amountMinor, 'balance': balanceMinor});
  }
}
