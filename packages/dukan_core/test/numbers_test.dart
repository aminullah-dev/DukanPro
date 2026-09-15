import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

/// The same rows as server/tests/unit/test_money_rules.py.
const _valid = <(String, int, int)>[
  ('12', 0, 12), ('۱۲', 0, 12), ('١٢', 0, 12), ('1.5', 3, 1500), ('۱٫۵', 3, 1500),
  ('.5', 2, 50), ('1,000', 0, 1000), ('۱٬۰۰۰', 0, 1000), (' 7 ', 0, 7), ('-5', 0, -5),
  ('12.50', 2, 1250), ('0', 2, 0),
];
const _notANumber = [
  'abc', '0x10', '1_000', '1.-5', '1. 5', '--5', '.', '', '1.2.3', '+5', '5.', '1,00', '12,5', '۱۲a',
];

Matcher _code(String code) => throwsA(isA<AppError>().having((e) => e.code, 'code', code));

void main() {
  group('typed numbers', () {
    for (final (text, places, want) in _valid) {
      test('"$text" with $places places is $want', () => expect(parseScaled(text, places).value, want));
    }
    for (final text in _notANumber) {
      test('"$text" is not a number', () => expect(parseScaled(text, 2).problem, NumberProblem.notANumber));
    }
    test('more decimals than allowed', () {
      expect(parseScaled('1.5', 0).problem, NumberProblem.tooPrecise);
      expect(parseScaled('1.234', 2).problem, NumberProblem.tooPrecise);
    });
    test('nothing past 2^53 - 1', () {
      expect(parseScaled('9007199254740991', 0).value, moneyMax);
      expect(parseScaled('9007199254740992', 0).problem, NumberProblem.tooLarge);
      expect(parseScaled('90071992547409.92', 2).problem, NumberProblem.tooLarge);
    });
    test('quantities and amounts raise their own codes', () {
      expect(quantityToMinor('۵', 0), 5);
      expect(quantityToMinor('۲٫۵', 3), 2500);
      expect(() => quantityToMinor('abc', 0), _code('CATALOG_QTY_INVALID'));
      expect(() => quantityToMinor('1.5', 0), _code('CATALOG_UNIT_PRECISION'));
      expect(moneyToMinor('۱۲۰'), 12000);
      expect(() => moneyToMinor('12.345'), _code('MONEY_AMOUNT_INVALID'));
    });
  });
}
