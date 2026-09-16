/// [text] with Persian (۰-۹) and Arabic-Indic (٠-٩) digits made ASCII, one for
/// one (the length stays the same), to compare what a Dari keyboard typed with
/// what is stored: a phone number, a SKU, a barcode.
String latinDigits(String text) => String.fromCharCodes(text.codeUnits.map((c) => c >= 0x06F0 && c <= 0x06F9
    ? 0x30 + c - 0x06F0
    : c >= 0x0660 && c <= 0x0669
        ? 0x30 + c - 0x0660
        : c));

bool _isDigit(int c) => c >= 0x30 && c <= 0x39;

/// Whether [typed] is what a barcode scanner typing [code] put into a text
/// field. A scanner sends key positions, and the active keyboard layout makes
/// characters of them: its digits come out as digits (Latin or Persian), but a
/// Dari layout turns its letters into Persian letters. So: the same length, the
/// same digits, and a non-Latin character wherever the code has a letter or a
/// symbol (or that very character, under a Latin layout).
bool typedByScan(String typed, String code) {
  if (typed.length != code.length) return false;
  final t = latinDigits(typed);
  for (var i = 0; i < code.length; i++) {
    final c = code.codeUnitAt(i);
    final k = t.codeUnitAt(i);
    if (k == c || (!_isDigit(c) && k > 0x7F)) continue;
    return false;
  }
  return true;
}

/// Whether [text] ends with what a scanner typing [code] put there. With
/// [needDigit], a code of letters alone must match exactly: for a field the
/// scan may not have gone into, so a Dari word is never taken for one.
bool endsWithScan(String text, String code, {bool needDigit = false}) {
  if (text.length < code.length) return false;
  final tail = text.substring(text.length - code.length);
  if (latinDigits(tail) == code) return true;
  if (needDigit && !code.codeUnits.any(_isDigit)) return false;
  return typedByScan(tail, code);
}

