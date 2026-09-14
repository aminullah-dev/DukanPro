// A payment to a supplier: positive, and no more than owed. The same rows as
// server/tests/unit/test_supplier_payment_rule.py.
import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

void main() {
  test('a supplier payment is positive and within the balance', () {
    Matcher code(String c) => throwsA(isA<AppError>().having((e) => e.code, 'code', c));
    expect(() => assertSupplierPaymentValid(amountMinor: 0, balanceMinor: 4000), code('SUPPLIER_PAYMENT_INVALID'));
    expect(() => assertSupplierPaymentValid(amountMinor: 4001, balanceMinor: 4000), code('SUPPLIER_OVERPAYMENT'));
    assertSupplierPaymentValid(amountMinor: 1500, balanceMinor: 4000);
  });
}
