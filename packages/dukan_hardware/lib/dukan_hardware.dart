/// DukanPro hardware ports. Implementations are owned by us (thin platform
/// channels / TCP sockets) so no vendor plugin leaks into the app. Preferred
/// transports: HID scanners (keyboard), camera scan (ML Kit), and ESC/POS over
/// TCP :9100 (pure Dart sockets) — with Bluetooth/USB as secondary.
library;

export 'src/escpos.dart';
export 'src/raster.dart';
export 'src/receipt.dart';
export 'src/tcp_printer.dart';

/// A decoded barcode scan.
final class ScanEvent {
  const ScanEvent(this.code, this.symbology);
  final String code;
  final String symbology; // ean13, code128, qr, …
}

/// Source of scans: an HID keyboard-wedge scanner, the camera, or an
/// integrated rugged-device scanner (Zebra/Honeywell via DataWedge intents).
abstract interface class BarcodeScanner {
  Stream<ScanEvent> scans();
}

/// How a thermal printer is reached.
enum PrinterTransport { tcp, bluetooth, usb }

/// An ESC/POS thermal receipt printer. Receipt layout is built per-locale and
/// fonts are embedded; see docs/localization.md.
abstract interface class ReceiptPrinter {
  PrinterTransport get transport;

  /// Print raw ESC/POS bytes (the receipt renderer produces these).
  Future<void> printRaw(List<int> escPosBytes);

  /// Open the cash drawer via the printer's kick connector.
  Future<void> kickCashDrawer();
}

/// A standalone cash drawer (when not kicked via the printer).
abstract interface class CashDrawer {
  Future<void> open();
}
