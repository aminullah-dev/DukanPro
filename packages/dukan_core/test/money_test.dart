import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    test('adds and subtracts within a currency', () {
      expect(Money(500, 'AFN') + Money(250, 'AFN'), Money(750, 'AFN'));
      expect(Money(500, 'AFN') - Money(200, 'AFN'), Money(300, 'AFN'));
    });

    test('scales by a whole quantity', () {
      expect(Money(520, 'AFN') * 3, Money(1560, 'AFN'));
    });

    test('rejects cross-currency arithmetic', () {
      expect(() => Money(500, 'AFN') + Money(5, 'USD'),
          throwsA(isA<ValidationError>()));
    });

    test('validates ISO-4217 shape', () {
      expect(() => Money(1, 'afn').validated(), throwsA(isA<ValidationError>()));
      expect(() => Money(1, 'AF').validated(), throwsA(isA<ValidationError>()));
      expect(Money(1, 'AFN').validated(), Money(1, 'AFN'));
    });

    // amountMinor is `int` by type — a float literal does not compile, which is
    // the compile-time proof that floats never enter a money path.
  });
}
