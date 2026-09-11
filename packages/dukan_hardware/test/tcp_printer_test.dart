import 'dart:async';
import 'dart:io';

import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:test/test.dart';

void main() {
  test('printRaw sends the bytes to a listening socket', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    final received = Completer<List<int>>();
    server.listen((socket) {
      final buf = <int>[];
      socket.listen(buf.addAll, onDone: () => received.complete(buf));
    });

    final printer = TcpReceiptPrinter(host: server.address.address, port: server.port);
    await printer.printRaw(const [0x1B, 0x40, 0x41, 0x42]); // ESC @ A B

    expect(printer.transport, PrinterTransport.tcp);
    expect(await received.future.timeout(const Duration(seconds: 5)), [0x1B, 0x40, 0x41, 0x42]);
  });

  test('kickCashDrawer sends the drawer pulse', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    final received = Completer<List<int>>();
    server.listen((socket) {
      final buf = <int>[];
      socket.listen(buf.addAll, onDone: () => received.complete(buf));
    });

    final printer = TcpReceiptPrinter(host: server.address.address, port: server.port);
    await printer.kickCashDrawer();
    expect(await received.future.timeout(const Duration(seconds: 5)),
        EscPosEncoder.drawerKick());
  });
}
