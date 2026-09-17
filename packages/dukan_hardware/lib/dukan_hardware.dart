/// DukanPro hardware ports. This package stays pure Dart: the TCP printer lives
/// here, and the vendor plugins for camera scanning and for Bluetooth and USB
/// printers stay inside the app's infrastructure adapters, behind these ports,
/// so no plugin type reaches the till. Transports: HID (keyboard-wedge) and
/// camera scanners; ESC/POS over TCP :9100, Bluetooth Classic, BLE and USB.
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
enum PrinterTransport {
  /// ESC/POS over TCP, usually port 9100, on Wi-Fi or a LAN cable.
  tcp,

  /// Bluetooth Classic (SPP), which most small receipt printers speak. Android
  /// only: iOS has no API for it.
  bluetooth,

  /// Bluetooth Low Energy: the only Bluetooth printers an iPhone or iPad can use.
  ble,

  /// A printer on the device's USB port. Android only.
  usb,
}

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
