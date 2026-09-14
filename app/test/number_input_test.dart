import 'package:dukan_core/dukan_core.dart';
import 'package:dukanpro/l10n/app_localizations_en.dart';
import 'package:dukanpro/widgets/number_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l = AppLocalizationsEn();

  test('amounts take Persian digits and are never negative', () {
    expect(amountOrNull('۱۲۰'), 12000);
    expect(amountOrNull('۲۵۰٫۵۰'), 25050);
    expect(amountOrNull('1,500'), 150000);
    expect(amountOrNull('  '), isNull);
    expect(() => amountOrNull('-50'), throwsA(isA<ValidationError>()));
    expect(() => amountOrNull('12.345'), throwsA(isA<ValidationError>()));
    expect(() => amountOrNull('۱۲a'), throwsA(isA<ValidationError>()));
  });

  test('a refused number reads as a sentence, not a code', () {
    expect(numberErrorText(l, ValidationError('MONEY_AMOUNT_INVALID')), l.errAmountInvalid);
    expect(numberErrorText(l, ValidationError('CATALOG_UNIT_PRECISION')), l.errQtyPrecision);
    expect(numberErrorText(l, ValidationError('GRN_LINE_INVALID')), l.errMustBePositive);
    expect(numberErrorText(l, ConflictError('PRODUCT_DUPLICATE_SKU')), isNull);
  });
}
