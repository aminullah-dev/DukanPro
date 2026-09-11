import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/app_shell.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/pos/receipt_builder.dart';
import 'package:dukanpro/features/settings/settings_providers.dart';
import 'package:dukanpro/infrastructure/keyboard_wedge_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WedgeDecoder', () {
    test('a fast burst ending in Enter decodes to a code', () {
      final d = WedgeDecoder();
      var t = DateTime(2026);
      String? out;
      for (final ch in '5901234'.split('')) {
        out = d.feed(ch, t);
        expect(out, isNull);
        t = t.add(const Duration(milliseconds: 10));
      }
      out = d.feed('\n', t);
      expect(out, '5901234');
    });

    test('slow (human) typing resets the buffer', () {
      final d = WedgeDecoder(maxGap: const Duration(milliseconds: 50));
      var t = DateTime(2026);
      d.feed('9', t);
      t = t.add(const Duration(seconds: 2)); // long pause → human
      d.feed('9', t);
      // Only the second '9' survives the reset.
      expect(d.feed('\n', t), '9');
    });

    test('guessSymbology classifies by shape', () {
      expect(guessSymbology('5901234123457'), 'ean13');
      expect(guessSymbology('ABC-1'), 'code128');
    });
  });

  group('PrinterConfig', () {
    test('round-trips through JSON', () {
      const c = PrinterConfig(enabled: true, host: '192.168.1.50', port: 9100);
      final back = PrinterConfig.fromJson(c.toJson());
      expect(back.enabled, isTrue);
      expect(back.host, '192.168.1.50');
      expect(back.port, 9100);
      expect(back.isReady, isTrue);
    });

    test('is not ready when disabled or host is blank', () {
      expect(const PrinterConfig(enabled: false, host: 'x').isReady, isFalse);
      expect(const PrinterConfig(enabled: true, host: '').isReady, isFalse);
    });
  });

  test('SettingsStore persists and reads back a value', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final store = SettingsStore(db);
    expect(await store.get('printer'), isNull);
    await store.set('printer', '{"enabled":true}');
    expect(await store.get('printer'), '{"enabled":true}');
  });

  test('receiptPrinterProvider builds a printer only when configured', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    await container.read(printerSettingsControllerProvider.future);
    expect(container.read(receiptPrinterProvider), isNull); // default: off

    await container
        .read(printerSettingsControllerProvider.notifier)
        .save(const PrinterConfig(enabled: true, host: '10.0.0.5'));
    expect(container.read(receiptPrinterProvider), isNotNull);
  });

  test('buildReceipt maps a settled sale to printable lines', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = LocalCatalog(db);
    final sales = LocalSales(db);
    final p = Product(id: newId(), sku: 'P1', name: 'Soap', unitId: 'piece', sellPrice: Money(52000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    await catalog.adjust(productId: p.id, branchId: 'B1', qtyDelta: 10, actorId: 'u1', deviceId: 'app');
    final sale = await sales.settleCash(
      lines: [SaleLine(
        productId: p.id, name: 'Soap', qtyMinor: 2, decimalPlaces: 0,
        unitPriceMinor: 52000, unitCostMinor: 0, currency: 'AFN',
      )],
      tenderedMinor: 110000, branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    final lines = await sales.saleLinesFor(sale.id);

    final data = buildReceipt(shopName: 'My Shop', sale: sale, lines: lines);
    expect(data.shopName, 'My Shop');
    expect(data.number, sale.number);
    expect(data.totalMinor, 104000);
    expect(data.lines.single.name, 'Soap');
    expect(data.lines.single.qtyLabel, '×2');
  });

  test('isWideLayout flips at the tablet/desktop breakpoint', () {
    expect(isWideLayout(400), isFalse); // phone
    expect(isWideLayout(1280), isTrue); // desktop
    expect(isWideLayout(kWideBreakpoint), isTrue);
  });
}
