/// Numbers people type: amounts of money and quantities. Mirrors
/// server/dukan/domain/numbers.py.
///
/// Shops type Persian (۰-۹) or Arabic-Indic (٠-٩) digits as often as Latin
/// ones, `٫` as the decimal separator and `٬` or `,` between thousands. A value
/// becomes integer minor units without passing through a floating-point number.
library;

import '../shared/errors.dart';

/// The largest magnitude of a money amount or quantity: 2^53 − 1, exact as a
/// JSON number (the server's MONEY_MAX).
const moneyMax = 9007199254740991;

/// Why a typed number was refused.
enum NumberProblem { notANumber, tooPrecise, tooLarge }

final _grammar = RegExp(r'^(-)?([0-9]{1,3}(?:,[0-9]{3})+|[0-9]+)?(?:\.([0-9]+))?$');

/// What both parsers trim: Unicode white space, spelled out because Dart's trim
/// and Python's strip disagree on U+FEFF and U+001C–U+001F. All in the BMP.
bool _isSpace(int c) =>
    (c >= 0x09 && c <= 0x0D) ||
    (c >= 0x1C && c <= 0x20) ||
    c == 0x85 ||
    c == 0xA0 ||
    c == 0x1680 ||
    (c >= 0x2000 && c <= 0x200A) ||
    c == 0x2028 ||
    c == 0x2029 ||
    c == 0x202F ||
    c == 0x205F ||
    c == 0x3000 ||
    c == 0xFEFF;

String _trim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _isSpace(s.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _isSpace(s.codeUnitAt(end - 1))) {
    end--;
  }
  return s.substring(start, end);
}

/// [input] trimmed, with Persian and Arabic-Indic digits, `٫`, `٬` and the
/// minus sign made ASCII.
String normalizeDigits(String input) {
  final out = StringBuffer();
  for (final rune in _trim(input).runes) {
    if (rune >= 0x06F0 && rune <= 0x06F9) {
      out.writeCharCode(0x30 + rune - 0x06F0);
    } else if (rune >= 0x0660 && rune <= 0x0669) {
      out.writeCharCode(0x30 + rune - 0x0660);
    } else if (rune == 0x066B) {
      out.write('.'); // ARABIC DECIMAL SEPARATOR
    } else if (rune == 0x066C) {
      out.write(','); // ARABIC THOUSANDS SEPARATOR
    } else if (rune == 0x2212) {
      out.write('-'); // MINUS SIGN
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}

/// [input] as a whole number of 10^-[decimalPlaces] units ('12.5' with 2
/// places is 1250), or the [NumberProblem] that stops it. Thousands marks must
/// group by three; anything else (signs other than a leading '-', spaces
/// inside, a trailing '.') is not a number.
({int? value, NumberProblem? problem}) parseScaled(String input, int decimalPlaces) {
  final m = _grammar.firstMatch(normalizeDigits(input));
  if (m == null) return (value: null, problem: NumberProblem.notANumber);
  final whole = (m.group(2) ?? '').replaceAll(',', '');
  final frac = m.group(3) ?? '';
  if (whole.isEmpty && frac.isEmpty) return (value: null, problem: NumberProblem.notANumber);
  if (frac.length > decimalPlaces) return (value: null, problem: NumberProblem.tooPrecise);
  final magnitude = BigInt.parse('${whole.isEmpty ? '0' : whole}${frac.padRight(decimalPlaces, '0')}');
  if (magnitude > BigInt.from(moneyMax)) return (value: null, problem: NumberProblem.tooLarge);
  final value = magnitude.toInt();
  return (value: m.group(1) == null ? value : -value, problem: null);
}

/// An amount of money typed in a currency with [decimalPlaces] minor digits
/// (AFN: 2). Raises [ValidationError] `MONEY_AMOUNT_INVALID`.
int moneyToMinor(String input, {int decimalPlaces = 2}) {
  final parsed = parseScaled(input, decimalPlaces);
  final value = parsed.value;
  if (value == null) {
    throw ValidationError('MONEY_AMOUNT_INVALID', {'input': input, 'reason': parsed.problem!.name});
  }
  return value;
}
