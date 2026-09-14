import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

CustomerLedgerEntry _e(LedgerEntryType t, int amt) => CustomerLedgerEntry(
      id: 'e', customerId: 'c', type: t, amountMinor: amt, currency: 'AFN',
      occurredAt: DateTime.utc(2026, 9, 11),
    );

void main() {
  test('customer balance derives from the ledger', () {
    expect(ledgerBalance([_e(LedgerEntryType.charge, 50000), _e(LedgerEntryType.payment, 20000)]), 30000);
  });

  test('credit limit: within ok, over throws, null = unlimited', () {
    assertWithinCreditLimit(balanceMinor: 30000, chargeMinor: 40000, creditLimitMinor: 100000);
    expect(
      () => assertWithinCreditLimit(balanceMinor: 90000, chargeMinor: 40000, creditLimitMinor: 100000),
      throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'SALE_OVER_CREDIT_LIMIT')),
    );
    assertWithinCreditLimit(balanceMinor: 90000, chargeMinor: 40000, creditLimitMinor: null);
  });

  test('overpayment throws DEBT_OVERPAYMENT', () {
    expect(
      () => assertNotOverpaid(balanceMinor: 30000, paymentMinor: 50000),
      throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'DEBT_OVERPAYMENT')),
    );
    assertNotOverpaid(balanceMinor: 30000, paymentMinor: 30000);
  });

  test('supplier balance derives from the ledger', () {
    final bill = SupplierLedgerEntry(
        id: 's', supplierId: 'sup', type: SupplierEntryType.bill, amountMinor: 400000,
        currency: 'AFN', occurredAt: DateTime.utc(2026, 9, 11));
    final pay = SupplierLedgerEntry(
        id: 's2', supplierId: 'sup', type: SupplierEntryType.payment, amountMinor: 150000,
        currency: 'AFN', occurredAt: DateTime.utc(2026, 9, 11));
    expect(supplierBalance([bill, pay]), 250000);
  });

  test('receipt line cost', () {
    expect(const ReceiptLine(productId: 'p', qtyMinor: 10, unitCostMinor: 40000, decimalPlaces: 0).lineCost, 400000);
    // 2.500 kg at 40.00 AFN/kg is a 100.00 AFN bill (server/tests/unit/test_money_rules.py).
    expect(const ReceiptLine(productId: 'p', qtyMinor: 2500, unitCostMinor: 4000, decimalPlaces: 3).lineCost, 10000);
  });

  test('a debt payment is a positive amount', () {
    for (final amount in [0, -500]) {
      expect(() => assertDebtPaymentValid(amountMinor: amount),
          throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'DEBT_PAYMENT_INVALID')));
    }
    assertDebtPaymentValid(amountMinor: 1);
  });
}
