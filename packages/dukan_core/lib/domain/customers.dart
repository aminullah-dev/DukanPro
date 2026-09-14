import '../shared/errors.dart';

/// Customers & debt domain. Mirrors docs/domain/customers-debt.md and
/// server/dukan/domain/customers.py. Balance is derived from an append-only
/// ledger; nothing is a stored mutable total.

enum LedgerEntryType { opening, charge, payment, adjustment }

final class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.creditLimitMinor,
    this.currency = 'AFN',
    this.isActive = true,
    this.version = 0,
  });

  final String id;
  final String name;
  final String? phone;
  final int? creditLimitMinor;
  final String currency;
  final bool isActive;
  final int version;
}

final class CustomerLedgerEntry {
  const CustomerLedgerEntry({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.occurredAt,
    this.refType,
    this.refId,
  });

  final String id;
  final String customerId;
  final LedgerEntryType type;
  final int amountMinor;
  final String currency;
  final String? refType;
  final String? refId;
  final DateTime occurredAt;

  /// Signed contribution to the balance: charges/openings add, payments subtract.
  int get signed => switch (type) {
        LedgerEntryType.charge => amountMinor,
        LedgerEntryType.opening => amountMinor,
        LedgerEntryType.adjustment => amountMinor,
        LedgerEntryType.payment => -amountMinor,
      };
}

/// Balance owed by the customer = Σ charges − Σ payments (positive = owes shop).
int ledgerBalance(Iterable<CustomerLedgerEntry> entries) =>
    entries.fold(0, (sum, e) => sum + e.signed);

/// Raises `SALE_OVER_CREDIT_LIMIT` if a new charge would exceed the limit.
void assertWithinCreditLimit({
  required int balanceMinor,
  required int chargeMinor,
  int? creditLimitMinor,
}) {
  if (creditLimitMinor != null && balanceMinor + chargeMinor > creditLimitMinor) {
    throw ConflictError('SALE_OVER_CREDIT_LIMIT', {
      'limit': creditLimitMinor,
      'balance': balanceMinor,
      'attempted': chargeMinor,
    });
  }
}

/// Raises `DEBT_OVERPAYMENT` if a payment exceeds the outstanding balance.
void assertNotOverpaid({required int balanceMinor, required int paymentMinor}) {
  if (paymentMinor > balanceMinor) {
    throw ConflictError('DEBT_OVERPAYMENT', {'balance': balanceMinor, 'payment': paymentMinor});
  }
}

/// A credit limit is null (unlimited) or a non-negative amount. Raises
/// [ValidationError] `CUSTOMER_CREDIT_LIMIT_INVALID`.
void assertCreditLimitValid({required int? creditLimitMinor}) {
  if (creditLimitMinor != null && creditLimitMinor < 0) {
    throw ValidationError('CUSTOMER_CREDIT_LIMIT_INVALID', {'limit': creditLimitMinor});
  }
}
