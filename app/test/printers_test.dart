// Bluetooth, BLE and USB receipt printers: settings find one and keep it, the
// till prints through the same printer the test print uses, and a print job
// always lets go of its connection.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/settings/printer_settings_screen.dart';
import 'package:dukanpro/features/settings/settings_providers.dart';
import 'package:dukanpro/infrastructure/plugin_printers.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what a print job did with its connection.
final class _Link implements PrinterLink {
  _Link(this.log, {this.failWrite = false, this.deny = false});
  final List<String> log;
  final bool failWrite;
  final bool deny;

  @override
  Future<void> open(Duration timeout) async {
    if (deny) throw const PrinterAccessDenied();
    log.add('open');
  }

  @override
  Future<void> write(List<int> bytes) async {
    if (failWrite) throw StateError('the printer went away');
    log.add('write ${bytes.length}');
  }

  @override
  Future<void> close() async => log.add('close');
}

/// A search that finds [printers] in two steps, as a real one grows its list.
final class _Finder implements PrinterFinder {
  _Finder(this.printers, {this.deny = false});
  final List<FoundPrinter> printers;
  final bool deny;
  final searched = <PrinterTransport>[];

  @override
  Stream<List<FoundPrinter>> find(PrinterTransport transport, {Duration timeout = const Duration(seconds: 8)}) async* {
    searched.add(transport);
    if (deny) throw const PrinterAccessDenied();
    yield printers.take(1).toList();
    yield printers;
  }
}

const _others = [PrinterTransport.bluetooth, PrinterTransport.ble, PrinterTransport.usb];

void main() {
  group('PrinterConfig', () {
    test('a Bluetooth printer round-trips through JSON', () {
      const c = PrinterConfig(
        enabled: true, transport: PrinterTransport.bluetooth, deviceId: 'AA:BB:CC:DD:EE:FF', deviceName: 'RPP02N',
        paperMm: 58,
      );
      final back = PrinterConfig.fromJson(c.toJson());
      expect(back.transport, PrinterTransport.bluetooth);
      expect(back.deviceId, 'AA:BB:CC:DD:EE:FF');
      expect(back.deviceName, 'RPP02N');
      expect(back.paperMm, 58);
      expect(back.isReady, isTrue);
    });

    test('a configuration saved before Bluetooth printers is still a network printer', () {
      final old = PrinterConfig.fromJson({'enabled': true, 'host': '192.168.1.50', 'port': 9100, 'paper_mm': 80});
      expect(old.transport, PrinterTransport.tcp);
      expect(old.isReady, isTrue);
      expect(PrinterConfig.fromJson({'transport': 'serial', 'host': 'x'}).transport, PrinterTransport.tcp);
    });

    test('a Bluetooth, BLE or USB printer is ready once one is chosen, whatever the host says', () {
      for (final t in _others) {
        expect(PrinterConfig(enabled: true, transport: t, host: '192.168.1.50').isReady, isFalse, reason: t.name);
        expect(PrinterConfig(enabled: true, transport: t, deviceId: 'x').isReady, isTrue, reason: t.name);
        expect(PrinterConfig(transport: t, deviceId: 'x').isReady, isFalse, reason: '${t.name} while printing is off');
      }
    });
  });

  test('a network printer is reached over TCP, the rest through a link, and choosing one connects nothing', () {
    final log = <String>[];
    final container = ProviderContainer(overrides: [printerLinkProvider.overrideWithValue((_) => _Link(log))]);
    addTearDown(container.dispose);
    final printerFor = container.read(printerForProvider);
    expect(printerFor(const PrinterConfig(host: '10.0.0.9')), isA<TcpReceiptPrinter>());
    for (final t in _others) {
      final printer = printerFor(PrinterConfig(transport: t, deviceId: 'x'));
      expect(printer, isA<LinkReceiptPrinter>(), reason: t.name);
      expect(printer.transport, t);
    }
    expect(log, isEmpty);
  });

  test("a saved BLE printer is the till's printer", () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final log = <String>[];
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      printerLinkProvider.overrideWithValue((_) => _Link(log)),
    ]);
    addTearDown(container.dispose);
    await container.read(printerSettingsControllerProvider.future);
    await container.read(printerSettingsControllerProvider.notifier).save(
          const PrinterConfig(enabled: true, transport: PrinterTransport.ble, deviceId: 'ble-1', deviceName: 'Printer'),
        );
    final printer = container.read(receiptPrinterProvider);
    expect(printer, isA<LinkReceiptPrinter>());
    await printer!.printRaw([1, 2, 3]);
    expect(log, ['open', 'write 3', 'close']);
  });

  group('LinkReceiptPrinter', () {
    test('every job opens its own connection, sends everything, and closes it', () async {
      var links = 0;
      final log = <String>[];
      final printer = LinkReceiptPrinter(
        transport: PrinterTransport.usb,
        link: () {
          links++;
          return _Link(log);
        },
      );
      await printer.printRaw([1, 2]);
      await printer.kickCashDrawer();
      expect(links, 2);
      expect(log, ['open', 'write 2', 'close', 'open', 'write ${EscPosEncoder.drawerKick().length}', 'close']);
    });

    test('a failed write still closes the connection, and the failure reaches the till', () async {
      final log = <String>[];
      final printer = LinkReceiptPrinter(transport: PrinterTransport.bluetooth, link: () => _Link(log, failWrite: true));
      await expectLater(printer.printRaw([1]), throwsStateError);
      expect(log, ['open', 'close']);
    });

    test('Bluetooth the device refused is PrinterAccessDenied, with nothing left open', () async {
      final log = <String>[];
      final printer = LinkReceiptPrinter(transport: PrinterTransport.ble, link: () => _Link(log, deny: true));
      await expectLater(printer.printRaw([1]), throwsA(isA<PrinterAccessDenied>()));
      expect(log, ['close']);
    });
  });

  group('settings', () {
    SessionActor owner() => SessionActor(
          User(
            id: 'u1', username: 'owner', displayName: 'Owner', status: UserStatus.active,
            assignments: [BranchAssignment(branchId: 'B1', roleName: 'owner')], defaultBranchId: 'B1',
          ),
          'B1',
        );

    Future<ProviderContainer> settings(
      WidgetTester tester, {
      required List<PrinterTransport> transports,
      PrinterFinder? finder,
    }) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() async => db.close());
      final container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        sessionActorProvider.overrideWithValue(owner()),
        printerTransportsProvider.overrideWithValue(transports),
        if (finder != null) printerFinderProvider.overrideWithValue(finder),
        printerLinkProvider.overrideWithValue((_) => _Link([])),
      ]);
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PrinterSettingsScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      return container;
    }

    Future<void> choose(WidgetTester tester, String current, String transport) async {
      await tester.tap(find.text(current));
      await tester.pumpAndSettle();
      await tester.tap(find.text(transport).last); // the open menu, not the button's own copy
      await tester.pumpAndSettle();
    }

    testWidgets('a Bluetooth printer is found, chosen and kept', (tester) async {
      final finder = _Finder(const [
        FoundPrinter(transport: PrinterTransport.bluetooth, id: 'AA:BB:CC:DD:EE:01', name: 'RPP02N'),
        FoundPrinter(transport: PrinterTransport.bluetooth, id: 'AA:BB:CC:DD:EE:02', name: 'XP-58'),
      ]);
      final container = await settings(tester, transports: const [PrinterTransport.tcp, ..._others], finder: finder);

      await tester.tap(find.text('Print receipts'));
      await tester.pumpAndSettle();
      await choose(tester, 'Network (Wi-Fi or cable)', 'Bluetooth');
      expect(find.text('Printer IP address'), findsNothing);
      expect(find.text('No printer chosen yet.'), findsOneWidget);

      await tester.tap(find.text('Find printers'));
      await tester.pumpAndSettle();
      expect(finder.searched, [PrinterTransport.bluetooth]);
      await tester.tap(find.text('XP-58'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = container.read(printerSettingsControllerProvider).value!;
      expect(saved.transport, PrinterTransport.bluetooth);
      expect(saved.deviceId, 'AA:BB:CC:DD:EE:02');
      expect(saved.deviceName, 'XP-58');
      expect(saved.isReady, isTrue);
    });

    testWidgets('a refused permission is said as that, not as no printers found', (tester) async {
      await settings(
        tester,
        transports: const [PrinterTransport.tcp, PrinterTransport.ble],
        finder: _Finder(const [], deny: true),
      );
      await tester.tap(find.text('Print receipts'));
      await tester.pumpAndSettle();
      await choose(tester, 'Network (Wi-Fi or cable)', 'Bluetooth LE');
      await tester.tap(find.text('Find printers'));
      await tester.pumpAndSettle();
      expect(
        find.text("DukanPro may not use Bluetooth or USB. Allow it in this device's settings, then try again."),
        findsOneWidget,
      );
    });

    testWidgets("only this device's ways to reach a printer are offered", (tester) async {
      await settings(tester, transports: const [PrinterTransport.tcp, PrinterTransport.ble]);
      await tester.tap(find.text('Print receipts'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Network (Wi-Fi or cable)'));
      await tester.pumpAndSettle();
      expect(find.text('Bluetooth LE'), findsWidgets);
      expect(find.text('Bluetooth'), findsNothing); // no Bluetooth Classic API on iOS
      expect(find.text('USB'), findsNothing);
    });

    testWidgets('a device with network printers only asks nothing about the connection', (tester) async {
      await settings(tester, transports: const [PrinterTransport.tcp]);
      expect(find.text('Connection'), findsNothing);
      expect(find.text('Printer IP address'), findsOneWidget);
    });
  });
}
