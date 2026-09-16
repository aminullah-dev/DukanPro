// What a return is worth and what it may take back; mirrors the server's
// tests/unit/test_sales_refund.py.
import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

Matcher _refused(String code) => throwsA(isA<ValidationError>().having((e) => e.code, 'code', code));

void main() {
  test('a returned part is worth its share of the line, rounded half up', () {
    expect(returnedValueMinor(lineTotalMinor: 1000, soldQtyMinor: 3, returnedQtyMinor: 1), 333);
    expect(returnedValueMinor(lineTotalMinor: 1000, soldQtyMinor: 3, returnedQtyMinor: 2), 667);
    expect(returnedValueMinor(lineTotalMinor: 900, soldQtyMinor: 3000, returnedQtyMinor: 1500), 450);
    expect(returnedValueMinor(lineTotalMinor: 5, soldQtyMinor: 2, returnedQtyMinor: 1), 3);
    // No 64-bit overflow on a large line.
    expect(returnedValueMinor(lineTotalMinor: 900000000000000, soldQtyMinor: 1000000, returnedQtyMinor: 999999),
        899999100000000);
  });

  test('a return gives back the goods less their share of the discount', () {
    expect(refundTotalMinor(grossMinor: 5000, saleSubtotalMinor: 10000, saleDiscountMinor: 1000), 4500);
    expect(refundTotalMinor(grossMinor: 5000, saleSubtotalMinor: 10000, saleDiscountMinor: 0), 5000);
  });

  test('a return says why and takes back no more than is left', () {
    const left = {'p': 2};
    expect(() => assertRefundValid(reason: '  ', wanted: {'p': 1}, returnable: left), _refused('REFUND_REASON_REQUIRED'));
    expect(() => assertRefundValid(reason: 'damaged', wanted: {}, returnable: left), _refused('REFUND_EMPTY'));
    for (final wanted in [{'p': 0}, {'p': 3}, {'q': 1}]) {
      expect(() => assertRefundValid(reason: 'damaged', wanted: wanted, returnable: left), _refused('REFUND_QTY_INVALID'));
    }
    assertRefundValid(reason: 'damaged', wanted: {'p': 2}, returnable: left);
  });
}
