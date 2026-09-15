import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';

/// Maps a settled sale + its lines into printable [ReceiptData]. Pure so it is
/// unit-testable without a printer or the database.
ReceiptData buildReceipt({
  required String shopName,
  required SaleRow sale,
  required List<SaleLineRow> lines,
  String zone = defaultBranchZone,
  String? footer,
}) =>
    ReceiptData(
      shopName: shopName,
      number: sale.number,
      stamp: receiptStamp(zone, sale.occurredAt),
      lines: [
        for (final l in lines)
          ReceiptLineData(
            name: l.name,
            qtyLabel: '×${formatQuantity(l.qtyMinor, l.decimalPlaces)}',
            lineTotalMinor: l.lineTotalMinor,
          ),
      ],
      subtotalMinor: sale.subtotalMinor,
      totalMinor: sale.totalMinor,
      paidMinor: sale.paidMinor,
      changeMinor: sale.changeMinor,
      currency: sale.currency,
      footer: footer,
    );

/// When a sale happened, for the paper: the branch's wall time, the Solar Hijri
/// date first and the Gregorian one in parentheses (a document that leaves the
/// shop carries both), in ASCII digits for ESC/POS text mode.
String receiptStamp(String zone, DateTime instant) {
  final local = branchWallClock(zone, instant);
  final solar = SolarHijriDate.fromGregorian(local);
  String two(int n) => n.toString().padLeft(2, '0');
  return '$solar ${two(local.hour)}:${two(local.minute)} (${local.year}-${two(local.month)}-${two(local.day)})';
}
