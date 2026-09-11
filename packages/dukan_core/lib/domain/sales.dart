import '../shared/errors.dart';

/// Sales / POS domain. Mirrors docs/domain/sales.md and
/// server/dukan/domain/sales.py. Money is integer minor units; quantities are
/// integer minor units of the product's unit (10^decimalPlaces granularity).

enum SaleStatus { open, settled, voided }

enum PaymentMethod { cash, card, credit }

int _scale(int decimalPlaces) {
  var r = 1;
  for (var i = 0; i < decimalPlaces; i++) {
    r *= 10;
  }
  return r;
}

/// Money value of [qtyMinor] units at [unitPriceMinor] per whole unit,
/// ROUND_HALF_UP. For a piece unit (decimalPlaces 0) this is price × qty.
int lineTotalMinor(int unitPriceMinor, int qtyMinor, int decimalPlaces) {
  final scale = _scale(decimalPlaces);
  final product = unitPriceMinor * qtyMinor;
  final negative = product < 0;
  final magnitude = product.abs();
  final rounded = (magnitude + scale ~/ 2) ~/ scale;
  return negative ? -rounded : rounded;
}

final class SaleLine {
  const SaleLine({
    required this.productId,
    required this.name,
    required this.qtyMinor,
    required this.decimalPlaces,
    required this.unitPriceMinor,
    required this.unitCostMinor,
    required this.currency,
  });

  final String productId;
  final String name; // snapshot for the receipt
  final int qtyMinor;
  final int decimalPlaces;
  final int unitPriceMinor; // snapshot at sale time
  final int unitCostMinor; // snapshot at sale time (for profit reports)
  final String currency;

  int get lineTotal => lineTotalMinor(unitPriceMinor, qtyMinor, decimalPlaces);
}

final class SaleTotals {
  const SaleTotals({required this.subtotalMinor, required this.taxMinor, required this.totalMinor});
  final int subtotalMinor;
  final int taxMinor;
  final int totalMinor;
}

/// Tax is computed per line then summed (Phase 3: 0% at the dukan level).
SaleTotals computeTotals(List<SaleLine> lines, {int discountMinor = 0}) {
  final subtotal = lines.fold<int>(0, (s, l) => s + l.lineTotal);
  const tax = 0;
  return SaleTotals(subtotalMinor: subtotal, taxMinor: tax, totalMinor: subtotal - discountMinor + tax);
}

/// Validate a settlement. [paidMinor] is the amount applied toward the balance.
/// Raises `SALE_EMPTY`, `SALE_CURRENCY_MISMATCH`, or (cash-only) `SALE_UNDERPAID`.
/// [allowCredit] is true once a customer is attached (the remainder goes to the
/// customer ledger — Phase 4).
void assertSettleable({
  required List<SaleLine> lines,
  required int totalMinor,
  required int paidMinor,
  required String currency,
  required bool allowCredit,
}) {
  if (lines.isEmpty) throw ValidationError('SALE_EMPTY', {});
  for (final l in lines) {
    if (l.currency != currency) {
      throw ConflictError('SALE_CURRENCY_MISMATCH', {'expected': currency, 'got': l.currency});
    }
  }
  if (!allowCredit && paidMinor < totalMinor) {
    throw ConflictError('SALE_UNDERPAID', {'total': totalMinor, 'paid': paidMinor});
  }
}
