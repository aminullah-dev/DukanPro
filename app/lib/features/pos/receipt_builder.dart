import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';

/// Maps a settled sale + its lines into printable [ReceiptData]. Pure so it is
/// unit-testable without a printer or the database.
ReceiptData buildReceipt({
  required String shopName,
  required SaleRow sale,
  required List<SaleLineRow> lines,
  String? footer,
}) =>
    ReceiptData(
      shopName: shopName,
      number: sale.number,
      dateTime: sale.createdAt.toLocal(),
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
