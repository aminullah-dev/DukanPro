/// [text] with Persian (۰-۹) and Arabic-Indic (٠-٩) digits made ASCII, one for
/// one (the length stays the same), to compare what a Dari keyboard typed with
/// what is stored: a phone number, a SKU, a barcode.
String latinDigits(String text) => String.fromCharCodes(text.codeUnits.map((c) => c >= 0x06F0 && c <= 0x06F9
    ? 0x30 + c - 0x06F0
    : c >= 0x0660 && c <= 0x0669
        ? 0x30 + c - 0x0660
        : c));
