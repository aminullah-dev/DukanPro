import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

SaleLine _line(int price, int qty, int dp, {int cost = 0, String cur = 'AFN'}) => SaleLine(
      productId: 'p', name: 'x', qtyMinor: qty, decimalPlaces: dp,
      unitPriceMinor: price, unitCostMinor: cost, currency: cur,
    );

void main() {
  group('lineTotalMinor', () {
    test('piece: price × qty', () => expect(lineTotalMinor(52000, 3, 0), 156000));
    test('kg: 1.5 kg at 10.00/kg', () => expect(lineTotalMinor(1000, 1500, 3), 1500));
    test('rounds half up', () => expect(lineTotalMinor(1500, 1, 3), 2));
  });

  test('computeTotals sums lines and subtracts discount', () {
    final t = computeTotals([_line(52000, 3, 0), _line(85000, 1, 0)], discountMinor: 1000);
    expect(t.subtotalMinor, 156000 + 85000);
    expect(t.totalMinor, 156000 + 85000 - 1000);
  });

  group('assertSettleable', () {
    test('empty -> SALE_EMPTY', () {
      expect(
        () => assertSettleable(lines: const [], totalMinor: 0, paidMinor: 0, currency: 'AFN', allowCredit: false),
        throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'SALE_EMPTY')),
      );
    });
    test('underpaid cash -> SALE_UNDERPAID', () {
      expect(
        () => assertSettleable(lines: [_line(500, 1, 0)], totalMinor: 500, paidMinor: 300, currency: 'AFN', allowCredit: false),
        throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'SALE_UNDERPAID')),
      );
    });
    test('credit allows underpay', () {
      assertSettleable(lines: [_line(500, 1, 0)], totalMinor: 500, paidMinor: 300, currency: 'AFN', allowCredit: true);
    });
    test('currency mismatch -> SALE_CURRENCY_MISMATCH', () {
      expect(
        () => assertSettleable(lines: [_line(500, 1, 0, cur: 'USD')], totalMinor: 500, paidMinor: 500, currency: 'AFN', allowCredit: false),
        throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'SALE_CURRENCY_MISMATCH')),
      );
    });
    test('exact cash ok', () {
      assertSettleable(lines: [_line(500, 1, 0)], totalMinor: 500, paidMinor: 500, currency: 'AFN', allowCredit: false);
    });
  });
}
