import '../shared/errors.dart';
import 'numbers.dart' show moneyMax;

/// Sales / POS domain. Mirrors docs/domain/sales.md and
/// server/dukan/domain/sales.py. Money is integer minor units; quantities are
/// integer minor units of the product's unit (10^decimalPlaces granularity).

enum SaleStatus { open, settled, voided }

/// How a sale or a debt is paid. `transfer` is mobile money or a bank transfer
/// (M-Paisa, HesabPay); `credit` is the unpaid rest on the customer's account,
/// never a payment.
enum PaymentMethod { cash, card, transfer, credit }

/// One payment taken for a sale: [amountMinor] toward the total and, for cash,
/// what was handed over ([tenderedMinor]; the difference is change).
final class Tender {
  const Tender(this.method, this.amountMinor, {this.tenderedMinor});
  final PaymentMethod method;
  final int amountMinor;
  final int? tenderedMinor;
}

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

/// Whether a line's money value stays within [moneyMax], the most a money
/// column or a JSON number holds. Asked before multiplying: a 64-bit product
/// wraps (2e15 pieces at 520.00 would come out negative).
bool lineTotalFits(int unitPriceMinor, int qtyMinor, int decimalPlaces) =>
    BigInt.from(unitPriceMinor).abs() * BigInt.from(qtyMinor).abs() <=
    BigInt.from(moneyMax) * BigInt.from(10).pow(decimalPlaces);

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

/// Every line sells a positive quantity at a price of zero or more, in the
/// sale's [currency], and the sale's total stays within [moneyMax]. Raises
/// [ValidationError] `SALE_EMPTY`, `SALE_LINE_INVALID_QTY`,
/// `SALE_LINE_INVALID_PRICE` or `SALE_TOTAL_TOO_LARGE`, or [ConflictError]
/// `SALE_CURRENCY_MISMATCH`.
void assertSaleLinesValid(List<SaleLine> lines, {required String currency}) {
  if (lines.isEmpty) throw ValidationError('SALE_EMPTY', {});
  var total = 0;
  for (final l in lines) {
    if (l.qtyMinor <= 0) {
      throw ValidationError('SALE_LINE_INVALID_QTY', {'product_id': l.productId, 'qty': l.qtyMinor});
    }
    if (l.unitPriceMinor < 0) {
      throw ValidationError('SALE_LINE_INVALID_PRICE', {'product_id': l.productId, 'price': l.unitPriceMinor});
    }
    if (l.currency != currency) {
      throw ConflictError('SALE_CURRENCY_MISMATCH', {'expected': currency, 'got': l.currency});
    }
    if (!lineTotalFits(l.unitPriceMinor, l.qtyMinor, l.decimalPlaces)) {
      throw ValidationError('SALE_TOTAL_TOO_LARGE', {'product_id': l.productId});
    }
    total += l.lineTotal; // each at most moneyMax, so the sum cannot wrap first
    if (total > moneyMax) throw ValidationError('SALE_TOTAL_TOO_LARGE', {});
  }
}

/// Validate a settlement. [paidMinor] is the amount offered toward the balance.
/// Raises what [assertSaleLinesValid] raises, `SALE_PAYMENT_INVALID` for a
/// negative amount, or (cash-only) `SALE_UNDERPAID`. [allowCredit] is true once
/// a customer is attached (the remainder goes to the customer ledger).
void assertSettleable({
  required List<SaleLine> lines,
  required int totalMinor,
  required int paidMinor,
  required String currency,
  required bool allowCredit,
}) {
  assertSaleLinesValid(lines, currency: currency);
  if (paidMinor < 0) {
    throw ValidationError('SALE_PAYMENT_INVALID', {'reason': 'amount', 'paid': paidMinor});
  }
  if (!allowCredit && paidMinor < totalMinor) {
    throw ConflictError('SALE_UNDERPAID', {'total': totalMinor, 'paid': paidMinor});
  }
}

/// A payment is a positive amount by cash, card or transfer: credit is the unpaid
/// remainder, never a payment. Cash handed over is at least the amount, and
/// only cash is handed over. Raises [ValidationError] `SALE_PAYMENT_INVALID`.
void assertPaymentValid({required PaymentMethod method, required int amountMinor, int? tenderedMinor}) {
  if (method == PaymentMethod.credit) {
    throw ValidationError('SALE_PAYMENT_INVALID', {'reason': 'method', 'method': method.name});
  }
  if (amountMinor <= 0) {
    throw ValidationError('SALE_PAYMENT_INVALID', {'reason': 'amount', 'amount': amountMinor});
  }
  if (tenderedMinor != null && (method != PaymentMethod.cash || tenderedMinor < amountMinor)) {
    throw ValidationError(
        'SALE_PAYMENT_INVALID', {'reason': 'tendered', 'amount': amountMinor, 'tendered': tenderedMinor});
  }
}

/// The payments applied to a sale never add up to more than its total: cash
/// over the total is change handed back, not a payment. Raises [ConflictError]
/// `SALE_OVERPAID`.
void assertSaleNotOverpaid({required int paidMinor, required int totalMinor}) {
  if (paidMinor > totalMinor) {
    throw ConflictError('SALE_OVERPAID', {'paid': paidMinor, 'total': totalMinor});
  }
}

/// A discount lies between 0 and the subtotal: a negative one is a hidden
/// surcharge, a larger one a negative total. Raises [ValidationError]
/// `SALE_DISCOUNT_INVALID`.
void assertDiscountValid({required int discountMinor, required int subtotalMinor}) {
  if (discountMinor < 0 || discountMinor > subtotalMinor) {
    throw ValidationError('SALE_DISCOUNT_INVALID', {'discount': discountMinor, 'subtotal': subtotalMinor});
  }
}

/// Cash in a drawer (a shift's opening float, the count at its close) is zero
/// or more. Raises [ValidationError] `SHIFT_CASH_INVALID`.
void assertShiftCashValid({required int amountMinor}) {
  if (amountMinor < 0) throw ValidationError('SHIFT_CASH_INVALID', {'amount': amountMinor});
}
