// Totals stay within moneyMax, drawer cash is never negative, and both number
// parsers trim the same characters. The same rows as
// server/tests/unit/test_bounds_and_trim.py.
import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

Matcher _code(String c) => throwsA(isA<AppError>().having((e) => e.code, 'code', c));

SaleLine _line(int qty, {int price = 52000, int places = 0}) => SaleLine(
      productId: 'p1', name: 'Soap', qtyMinor: qty, decimalPlaces: places,
      unitPriceMinor: price, unitCostMinor: 0, currency: 'AFN',
    );

ReceiptLine _receipt(int qty, int cost) =>
    ReceiptLine(productId: 'p1', qtyMinor: qty, unitCostMinor: cost, decimalPlaces: 0);

void main() {
  test('a line fits until its value passes moneyMax', () {
    expect(lineTotalFits(moneyMax, 1, 0), isTrue);
    expect(lineTotalFits(moneyMax, 2, 0), isFalse);
    expect(lineTotalFits(moneyMax, 1000, 3), isTrue); // 1.000 kg
    expect(lineTotalFits(52000, 2000000000000000, 0), isFalse); // would wrap a 64-bit product
  });

  test('a sale total past moneyMax is refused', () {
    expect(() => assertSaleLinesValid([_line(100000000000000)], currency: 'AFN'),
        _code('SALE_TOTAL_TOO_LARGE'));
    const half = moneyMax ~/ 2 + 1;
    expect(() => assertSaleLinesValid([_line(1, price: half), _line(1, price: half)], currency: 'AFN'),
        _code('SALE_TOTAL_TOO_LARGE'));
    assertSaleLinesValid([_line(1, price: moneyMax)], currency: 'AFN');
  });

  test('a receipt past moneyMax is refused', () {
    expect(() => assertReceivable(_receipt(moneyMax, moneyMax)), _code('GRN_TOTAL_TOO_LARGE'));
    final half = _receipt(1, moneyMax ~/ 2 + 1);
    expect(() => receiptTotal([half, half]), _code('GRN_TOTAL_TOO_LARGE'));
    expect(receiptTotal([half]), moneyMax ~/ 2 + 1);
  });

  test('drawer cash is never negative', () {
    expect(() => assertShiftCashValid(amountMinor: -1), _code('SHIFT_CASH_INVALID'));
    assertShiftCashValid(amountMinor: 0);
  });

  test('both parsers trim the same characters', () {
    for (final text in ['﻿12', '12﻿', '\x1C12\x1F', ' 　١٢\t']) {
      expect(parseScaled(text, 0).value, 12, reason: text.runes.toList().toString());
    }
  });
}
