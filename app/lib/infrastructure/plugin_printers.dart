import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter/foundation.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart' as plugin;

/// The ways this device can reach a printer, in the order settings offer them.
/// iOS has no Bluetooth Classic or USB API for printers, only BLE. macOS and
/// Windows keep network printers for now.
List<PrinterTransport> printerTransportsForPlatform() {
  if (kIsWeb) return const [PrinterTransport.tcp];
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => const [
        PrinterTransport.tcp,
        PrinterTransport.bluetooth,
        PrinterTransport.ble,
        PrinterTransport.usb,
      ],
    TargetPlatform.iOS => const [PrinterTransport.tcp, PrinterTransport.ble],
    _ => const [PrinterTransport.tcp],
  };
}

/// A printer a search found.
final class FoundPrinter {
  const FoundPrinter({required this.transport, required this.id, required this.name});
  final PrinterTransport transport;

  /// The Bluetooth address, the BLE device id, or the USB `vendor:product`.
  final String id;
  final String name;
}

/// The device refused Bluetooth or USB access, or the person said no.
final class PrinterAccessDenied implements Exception {
  const PrinterAccessDenied();
}

/// Looks for Bluetooth, BLE and USB printers.
abstract interface class PrinterFinder {
  /// The growing list of printers found on [transport], until [timeout].
  Stream<List<FoundPrinter>> find(PrinterTransport transport, {Duration timeout = const Duration(seconds: 8)});
}

/// One print job's connection to a Bluetooth, BLE or USB printer.
abstract interface class PrinterLink {
  Future<void> open(Duration timeout);

  /// Sends [bytes] and waits until the printer has taken all of them.
  Future<void> write(List<int> bytes);

  /// Closes the connection. Safe to call when it never opened.
  Future<void> close();
}

/// A receipt printer over Bluetooth, BLE or USB. Like the TCP printer it opens a
/// connection for each job and always closes it, so a printer that was switched
/// off, went to sleep or was paired again never leaves the till a dead link.
final class LinkReceiptPrinter implements ReceiptPrinter {
  const LinkReceiptPrinter({
    required this.transport,
    required this.link,
    this.connectTimeout = const Duration(seconds: 10),
  });

  @override
  final PrinterTransport transport;

  /// A fresh connection for one job.
  final PrinterLink Function() link;
  final Duration connectTimeout;

  @override
  Future<void> printRaw(List<int> escPosBytes) async {
    final connection = link();
    try {
      await connection.open(connectTimeout);
      await connection.write(escPosBytes);
    } finally {
      await connection.close();
    }
  }

  @override
  Future<void> kickCashDrawer() => printRaw(EscPosEncoder.drawerKick());
}

/// [PrinterLink] through unified_esc_pos_printer.
final class PluginPrinterLink implements PrinterLink {
  PluginPrinterLink({required this.transport, required this.id, required this.name});

  final PrinterTransport transport;
  final String id;
  final String name;
  plugin.PrinterConnector<plugin.PrinterDevice>? _connector;

  @override
  Future<void> open(Duration timeout) async {
    try {
      switch (transport) {
        case PrinterTransport.bluetooth:
          final connector = plugin.BluetoothConnector();
          _connector = connector;
          await connector.connect(plugin.BluetoothPrinterDevice(name: name, address: id), timeout: timeout);
        case PrinterTransport.ble:
          final connector = plugin.BleConnector();
          _connector = connector;
          await connector.connect(plugin.BlePrinterDevice(name: name, deviceId: id), timeout: timeout);
        case PrinterTransport.usb:
          final connector = plugin.UsbConnector();
          _connector = connector;
          await connector.connect(
            plugin.UsbPrinterDevice(name: name, identifier: id, usbPlatform: plugin.UsbPlatform.android),
            timeout: timeout,
          );
        case PrinterTransport.tcp:
          throw ArgumentError.value(transport, 'transport', 'a network printer is a TcpReceiptPrinter');
      }
    } on plugin.PrinterPermissionException {
      throw const PrinterAccessDenied();
    }
  }

  @override
  Future<void> write(List<int> bytes) async {
    final connector = _connector ?? (throw StateError('open the printer link before writing'));
    await connector.writeBytes(bytes);
    await connector.waitWriteComplete();
  }

  @override
  Future<void> close() async {
    final connector = _connector;
    _connector = null;
    if (connector == null) return;
    try {
      if (connector.state == plugin.PrinterConnectionState.connected) await connector.disconnect();
    } on Object {
      // The job already succeeded or failed in write: a failed goodbye changes neither.
    }
    try {
      await connector.dispose();
    } on Object {
      // Nothing it held is needed by a later job, which opens its own connector.
    }
  }
}

/// [PrinterFinder] through unified_esc_pos_printer. Bluetooth Classic lists the
/// printers paired in the device's settings first, then nearby ones; USB lists
/// what is plugged in.
final class PluginPrinterFinder implements PrinterFinder {
  const PluginPrinterFinder();

  @override
  Stream<List<FoundPrinter>> find(PrinterTransport transport, {Duration timeout = const Duration(seconds: 8)}) async* {
    final plugin.PrinterConnector<plugin.PrinterDevice> connector = switch (transport) {
      PrinterTransport.bluetooth => plugin.BluetoothConnector(),
      PrinterTransport.ble => plugin.BleConnector(),
      PrinterTransport.usb => plugin.UsbConnector(),
      PrinterTransport.tcp => throw ArgumentError.value(transport, 'transport', 'a network printer is typed in'),
    };
    try {
      await for (final devices in connector.scan(timeout: timeout)) {
        yield [for (final d in devices) FoundPrinter(transport: transport, id: _idOf(d), name: d.name)];
      }
    } on plugin.PrinterPermissionException {
      throw const PrinterAccessDenied();
    } finally {
      try {
        await connector.stopScan();
        await connector.dispose();
      } on Object {
        // A search that ended, or was cancelled, holds nothing a later one needs.
      }
    }
  }

  static String _idOf(plugin.PrinterDevice device) => switch (device) {
        plugin.BluetoothPrinterDevice(:final address) => address,
        plugin.BlePrinterDevice(:final deviceId) => deviceId,
        plugin.UsbPrinterDevice(:final identifier) => identifier,
        plugin.NetworkPrinterDevice(:final host) => host,
        _ => device.name,
      };
}
