import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

/// Mirrors server/tests/unit/test_insights.py.
void main() {
  group('reorderSuggestion', () {
    test('suggests nothing when stock covers lead + safety demand', () {
      expect(reorderSuggestion(onHandMinor: 1000, avgDailySalesMinor: 10), 0);
    });

    test('suggests a refill to twice the reorder point when low', () {
      // point = 10 * (7+3) = 100; target = 200; on-hand 20 → 180.
      expect(reorderSuggestion(onHandMinor: 20, avgDailySalesMinor: 10), 180);
    });

    test('never suggests for a product with no sales', () {
      expect(reorderSuggestion(onHandMinor: 0, avgDailySalesMinor: 0), 0);
    });
  });

  group('isDeadStock', () {
    test('flags stock unsold past the threshold', () {
      expect(isDeadStock(onHandMinor: 5, daysSinceLastSale: 45), isTrue);
    });
    test('does not flag recently sold or empty stock', () {
      expect(isDeadStock(onHandMinor: 5, daysSinceLastSale: 3), isFalse);
      expect(isDeadStock(onHandMinor: 0, daysSinceLastSale: 90), isFalse);
    });
  });

  group('debtSeverity', () {
    test('critical at or over the limit', () {
      expect(debtSeverity(balanceMinor: 100, creditLimitMinor: 100), InsightSeverity.critical);
    });
    test('warning at 80% of the limit', () {
      expect(debtSeverity(balanceMinor: 80, creditLimitMinor: 100), InsightSeverity.warning);
    });
    test('info below 80% or with no limit', () {
      expect(debtSeverity(balanceMinor: 50, creditLimitMinor: 100), InsightSeverity.info);
      expect(debtSeverity(balanceMinor: 500, creditLimitMinor: 0), InsightSeverity.info);
    });
  });
}
