import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

/// Mirrors docs/domain/catalog.md and server/tests/unit/test_catalog.py.
void main() {
  group('catalog invariants', () {
    test('duplicate sku rejected', () {
      expect(
        () => assertUniqueSku(sku: 'A1', taken: true),
        throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'PRODUCT_DUPLICATE_SKU')),
      );
      assertUniqueSku(sku: 'A1', taken: false); // no throw
    });

    test('duplicate barcode rejected', () {
      expect(
        () => assertUniqueBarcode(code: '5001', taken: true),
        throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'BARCODE_DUPLICATE')),
      );
    });
  });

  group('quantity precision', () {
    test('fractional quantity of a piece unit is rejected', () {
      expect(
        () => quantityToMinor('1.5', 0),
        throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'CATALOG_UNIT_PRECISION')),
      );
    });

    test('kg accepts 3 decimals and round-trips', () {
      expect(quantityToMinor('1.250', 3), 1250);
      expect(formatQuantity(1250, 3), '1.250');
    });

    test('whole units and negatives', () {
      expect(quantityToMinor('2', 0), 2);
      expect(formatQuantity(2, 0), '2');
      expect(quantityToMinor('-3', 0), -3);
      expect(formatQuantity(-1500, 3), '-1.500');
    });
  });

  test('product carries a Money price and tracks stock by default', () {
    final p = Product(id: newId(), sku: 'A1', name: 'Rice', unitId: 'kg', sellPrice: Money(52000, 'AFN'));
    expect(p.sellPrice, Money(52000, 'AFN'));
    expect(p.trackStock, isTrue);
  });
}
