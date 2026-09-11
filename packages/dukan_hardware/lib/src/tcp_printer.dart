import 'dart:io';

import '../dukan_hardware.dart';

/// ESC/POS thermal printer reached over TCP (the common networked setup:
/// raw port 9100). Pure `dart:io` — no vendor plugin. One short-lived socket
/// per job keeps it robust against printers that drop idle connections.
final class TcpReceiptPrinter implements ReceiptPrinter {
  const TcpReceiptPrinter({
    required this.host,
    this.port = 9100,
    this.timeout = const Duration(seconds: 5),
  });

  final String host;
  final int port;
  final Duration timeout;

  @override
  PrinterTransport get transport => PrinterTransport.tcp;

  @override
  Future<void> printRaw(List<int> escPosBytes) async {
    final socket = await Socket.connect(host, port, timeout: timeout);
    try {
      socket.add(escPosBytes);
      await socket.flush();
    } finally {
      await socket.close();
      socket.destroy();
    }
  }

  @override
  Future<void> kickCashDrawer() => printRaw(EscPosEncoder.drawerKick());
}
