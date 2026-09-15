// Theme 9c: money reads as a grouped figure with its currency, Latin tokens
// keep their order in Dari and Pashto lines, and a scan under a Dari keyboard
// layout still reads as the barcode.
import 'package:dukanpro/infrastructure/keyboard_wedge_scanner.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:dukanpro/widgets/bidi.dart';
import 'package:dukanpro/widgets/money.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fa = lookupAppLocalizations(const Locale('fa', 'AF'));
  final ps = lookupAppLocalizations(const Locale('ps'));

  test('money is a grouped Latin figure followed by the currency as the locale writes it', () {
    expect(amountText(125000000), ltr('1,250,000.00'));
    expect(amountText(-5050), ltr('-50.50')); // the minus stays in front in a Dari line
    expect(amountText(99), ltr('0.99'));
    expect(formatMoney(en, 104000, 'AFN'), '${ltr('1,040.00')} AFN');
    expect(formatMoney(fa, 104000, 'AFN'), '${ltr('1,040.00')} افغانی');
    expect(formatMoney(ps, 2500, 'USD'), '${ltr('25.00')} ${ps.symbolUsd}');
    expect(currencySymbol(fa, 'XYZ'), 'XYZ');
  });

  test('a phone number is isolated left to right', () {
    expect(ltr('+93 70 123 4567'), '\u2066+93 70 123 4567\u2069');
  });

  test('a scan under a Dari keyboard layout reads as the barcode', () {
    expect(scanCharFor(PhysicalKeyboardKey.digit5, '۵', shift: false), '5');
    expect(scanCharFor(PhysicalKeyboardKey.numpad7, '۷', shift: false), '7');
    expect(scanCharFor(PhysicalKeyboardKey.keyA, 'ش', shift: false), 'a');
    expect(scanCharFor(PhysicalKeyboardKey.keyA, 'ؤ', shift: true), 'A');
    expect(scanCharFor(PhysicalKeyboardKey.digit1, '1', shift: false), '1'); // a Latin layout
    expect(scanCharFor(PhysicalKeyboardKey.minus, '-', shift: false), '-');
    // Shifted digits and punctuation, as a scanner set up for a US keyboard means them.
    expect(scanCharFor(PhysicalKeyboardKey.digit3, '٫', shift: true), '#');
    expect(scanCharFor(PhysicalKeyboardKey.slash, '/', shift: false), '/');
    expect(scanCharFor(PhysicalKeyboardKey.minus, 'ـ', shift: false), '-');
    expect(scanCharFor(PhysicalKeyboardKey.period, 'ژ', shift: true), '>');

    final decoder = WedgeDecoder();
    var at = DateTime(2026);
    String? code;
    for (final ch in '۵۹۰۱۲۳۴۱۲۳۴۵۷\n'.split('')) {
      at = at.add(const Duration(milliseconds: 10));
      code = decoder.feed(ch, at) ?? code;
    }
    expect(code, '5901234123457');
    expect(guessSymbology(code!), 'ean13');
  });
}
