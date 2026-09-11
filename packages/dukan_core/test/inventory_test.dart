import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

/// Mirrors the test table in `docs/domain/inventory.md`. The same rows are
/// implemented in `server/tests/unit/test_inventory.py`.
void main() {
  final at = DateTime.utc(2026, 9, 11);

  StockMovement mv(int delta, StockReason reason) => StockMovement(
      id: newId(), productId: 'A1', branchId: 'B1', qtyDelta: delta,
      reason: reason, occurredAt: at);

  group('inventory', () {
    test('on-hand sums the ledger', () {
      final movements = [
        mv(10, StockReason.purchase),
        mv(-3, StockReason.sale),
      ];
      expect(onHand(movements), 7);
    });

    test('oversell (online) raises STOCK_INSUFFICIENT with available', () {
      expect(
        () => sellFromStock(
            id: newId(), productId: 'A1', branchId: 'B1',
            qty: 5, available: 2, at: at),
        throwsA(isA<ConflictError>()
            .having((e) => e.code, 'code', 'STOCK_INSUFFICIENT')
            .having((e) => e.context['available'], 'available', 2)),
      );
    });

    test('selling within stock yields a negative movement', () {
      final m = sellFromStock(
          id: newId(), productId: 'A1', branchId: 'B1',
          qty: 3, available: 7, at: at);
      expect(m.qtyDelta, -3);
      expect(m.reason, StockReason.sale);
    });

    test('non-positive qty raises STOCK_INVALID_QTY', () {
      expect(
        () => sellFromStock(
            id: newId(), productId: 'A1', branchId: 'B1',
            qty: 0, available: 7, at: at),
        throwsA(isA<ValidationError>()
            .having((e) => e.code, 'code', 'STOCK_INVALID_QTY')),
      );
    });
  });
}
