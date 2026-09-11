/// Purchasing domain. Mirrors docs/domain/purchasing.md and
/// server/dukan/domain/purchasing.py. Phase 4 uses a direct goods receipt
/// (no full PO lifecycle): receiving increments stock at cost and bills the
/// supplier. The supplier balance is derived from an append-only ledger.
library;

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

/// One line of a goods receipt: qty received at a unit cost (minor units).
final class ReceiptLine {
  const ReceiptLine({required this.productId, required this.qtyMinor, required this.unitCostMinor});
  final String productId;
  final int qtyMinor;
  final int unitCostMinor;

  int get lineCost => unitCostMinor * qtyMinor;
}
