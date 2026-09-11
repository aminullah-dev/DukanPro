// Printable receipt content. Pure data — the EscPosEncoder turns it into
// printer bytes; the UI can also render it on screen. Amounts are integer
// minor units (see dukan_core Money invariant).

final class ReceiptLineData {
  const ReceiptLineData({
    required this.name,
    required this.qtyLabel,
    required this.lineTotalMinor,
  });
  final String name;
  final String qtyLabel; // already formatted, e.g. "×2" or "×1.5 kg"
  final int lineTotalMinor;
}

final class ReceiptData {
  const ReceiptData({
    required this.shopName,
    required this.number,
    required this.dateTime,
    required this.lines,
    required this.subtotalMinor,
    required this.totalMinor,
    required this.paidMinor,
    required this.changeMinor,
    this.currency = 'AFN',
    this.footer,
  });

  final String shopName;
  final String number; // business invoice number, e.g. INV-2026-00417
  final DateTime dateTime;
  final List<ReceiptLineData> lines;
  final int subtotalMinor;
  final int totalMinor;
  final int paidMinor;
  final int changeMinor;
  final String currency;
  final String? footer;
}
