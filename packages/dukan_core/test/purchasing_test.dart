import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

void main() {
  test('a received line is a positive quantity at a cost of zero or more', () {
    final invalid = throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'GRN_LINE_INVALID'));
    expect(() => assertReceivable(const ReceiptLine(productId: 'p', qtyMinor: 0, unitCostMinor: 100)), invalid);
    expect(() => assertReceivable(const ReceiptLine(productId: 'p', qtyMinor: -5, unitCostMinor: 100)), invalid);
    expect(() => assertReceivable(const ReceiptLine(productId: 'p', qtyMinor: 5, unitCostMinor: -1)), invalid);
    assertReceivable(const ReceiptLine(productId: 'p', qtyMinor: 5, unitCostMinor: 0));
  });
}
