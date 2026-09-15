// Review of themes 6-9, the till: credit goes to the customer the field names,
// scans made while the till's own dialogs are open are kept (and never land in
// an amount), a scan into a search keeps both, Persian digits find what Latin
// ones do, and the POS's screens fit a small phone at large text sizes.
import 'dart:async';

import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/catalog/catalog_providers.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:dukanpro/features/pos/pos_screen.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _piece = '00000000-0000-7000-8000-000000000001';
final en = lookupAppLocalizations(const Locale('en'));

ScanEvent _scan([String code = '111']) => ScanEvent(code, 'ean13'); // a fresh event each time

class _Scanner implements BarcodeScanner {
  final controller = StreamController<ScanEvent>.broadcast();
  @override
  Stream<ScanEvent> scans() => controller.stream;
}

SessionActor _owner() => SessionActor(
      User(
        id: 'u1', username: 'owner', displayName: 'Owner', status: UserStatus.active,
        assignments: [BranchAssignment(branchId: 'B1', roleName: 'owner')], defaultBranchId: 'B1',
      ),
      'B1',
    );

void _size(WidgetTester tester, Size size, {double scale = 1.0, double keyboard = 0}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  if (scale != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  if (keyboard > 0) {
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
    addTearDown(tester.view.resetViewInsets);
  }
}

Future<ProviderContainer> _till(WidgetTester tester, _Scanner scanner, {bool shift = true, int price = 5000}) async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(() async => db.close());
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    sessionActorProvider.overrideWithValue(_owner()),
    deviceIdProvider.overrideWithValue('d1'),
    scannerProvider.overrideWithValue(scanner),
  ]);
  addTearDown(container.dispose);
  final catalog = container.read(localCatalogProvider);
  for (final (sku, name, code) in [('S1', 'Soap', '111'), ('5010', 'Tea', '222')]) {
    final p = Product(id: newId(), sku: sku, name: name, unitId: _piece, sellPrice: Money(price, 'AFN'));
    await catalog.createProduct(p, barcodes: [Barcode(id: newId(), productId: p.id, code: code)], actorId: 'u1', deviceId: 'd1');
    await catalog.adjust(productId: p.id, branchId: 'B1', qtyDelta: 100, actorId: 'u1', deviceId: 'd1');
  }
  final customers = LocalCustomers(db);
  await customers.createCustomer(Customer(id: newId(), name: 'Karim', phone: '0799123456'), actorId: 'u1', deviceId: 'd1');
  await customers.createCustomer(Customer(id: newId(), name: 'Ahmad Shah'), actorId: 'u1', deviceId: 'd1');
  if (shift) await LocalShifts(db).open(branchId: 'B1', userId: 'u1', openingFloatMinor: 0, deviceId: 'd1');
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PosScreen(),
    ),
  ));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _scanNow(WidgetTester tester, _Scanner scanner, [String code = '111']) async {
  scanner.controller.add(_scan(code));
  await tester.pumpAndSettle();
}

Finder _inDialog(Finder f) => find.descendant(of: find.byType(AlertDialog), matching: f);

void main() {
  testWidgets('credit goes only to the customer the field names', (tester) async {
    _size(tester, const Size(1280, 800));
    final scanner = _Scanner();
    await _till(tester, scanner);
    await _scanNow(tester, scanner);
    await tester.tap(find.byIcon(Icons.point_of_sale));
    await tester.pumpAndSettle();
    final customerField = _inDialog(find.byType(TextField)).last;
    await tester.enterText(customerField, 'Kar');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karim').last);
    await tester.pumpAndSettle();
    expect(_inDialog(find.widgetWithText(FilledButton, en.credit)), findsOneWidget);
    // Typed over, without picking anyone: nobody is picked, so no credit.
    await tester.enterText(customerField, 'Ahmad Shah');
    await tester.pumpAndSettle();
    expect(_inDialog(find.widgetWithText(FilledButton, en.credit)), findsNothing);
  });

  testWidgets("the next customer's items scanned during the receipt are kept", (tester) async {
    _size(tester, const Size(1280, 800));
    final scanner = _Scanner();
    final container = await _till(tester, scanner);
    await _scanNow(tester, scanner);
    await tester.tap(find.byIcon(Icons.point_of_sale));
    await tester.pumpAndSettle();
    await tester.tap(_inDialog(find.widgetWithText(FilledButton, en.charge)));
    await tester.pumpAndSettle();
    expect(find.text(en.receipt), findsWidgets);
    await _scanNow(tester, scanner);
    await _scanNow(tester, scanner);
    await tester.tap(find.text(en.newSale));
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.qtyMinor, 2);
  });

  testWidgets('a scan during the payment stays out of the amount and waits for the cart', (tester) async {
    _size(tester, const Size(1280, 800));
    final scanner = _Scanner();
    final container = await _till(tester, scanner);
    await _scanNow(tester, scanner);
    await tester.tap(find.byIcon(Icons.point_of_sale));
    await tester.pumpAndSettle();
    final tendered = _inDialog(find.byType(TextField)).first;
    final before = tester.widget<TextField>(tendered).controller!.text;
    // The scanner types like a keyboard: its digits land in the focused amount first.
    await tester.enterText(tendered, '${before}111');
    await _scanNow(tester, scanner);
    expect(tester.widget<TextField>(tendered).controller!.text, before);
    expect(container.read(posCartProvider).single.qtyMinor, 1); // the sale is unchanged
    await tester.tap(find.text(en.cancel));
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.qtyMinor, 2); // the scan came in after
  });

  testWidgets('a scan into a search that already holds text adds its product', (tester) async {
    _size(tester, const Size(1280, 800));
    final scanner = _Scanner();
    final container = await _till(tester, scanner);
    final search = find.byType(TextField).first;
    await tester.enterText(search, 'Soa');
    await tester.pump();
    await _scanNow(tester, scanner); // the event comes before the scanner's digits reach the field
    await tester.enterText(search, 'Soa111');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.product.name, 'Soap');
    expect(tester.widget<TextField>(search).controller!.text, 'Soa');
  });

  testWidgets('Persian digits find the product and the customer Latin ones do', (tester) async {
    _size(tester, const Size(1280, 800));
    final scanner = _Scanner();
    await _till(tester, scanner);
    await tester.enterText(find.byType(TextField).first, '۵۰۱');
    await tester.pumpAndSettle();
    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Soap'), findsNothing);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soap')); // the search field keeps focus: add by tapping
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.point_of_sale));
    await tester.pumpAndSettle();
    await tester.enterText(_inDialog(find.byType(TextField)).last, '۰۷۹۹');
    await tester.pumpAndSettle();
    expect(find.text('Karim'), findsWidgets);
  });

  testWidgets('the payment and the shift report fit a small phone at large text', (tester) async {
    for (final (size, scale) in [(const Size(320, 568), 1.3), (const Size(360, 640), 2.0)]) {
      _size(tester, size, scale: scale);
      final scanner = _Scanner();
      await _till(tester, scanner, price: 123456789);
      await _scanNow(tester, scanner);
      await tester.tap(find.byIcon(Icons.point_of_sale).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'payment at $size x$scale');
      await tester.tap(find.text(en.cancel));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.lock_clock_outlined));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'shift report at $size x$scale');
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('the shift gate scrolls above the keyboard; the side cart fits a landscape phone', (tester) async {
    _size(tester, const Size(320, 568), keyboard: 260);
    await _till(tester, _Scanner(), shift: false);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.widgetWithText(FilledButton, en.openShift));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.widgetWithText(FilledButton, en.openShift)).bottom, lessThanOrEqualTo(568 - 260));
    await tester.pumpWidget(const SizedBox());

    _size(tester, const Size(844, 390), keyboard: 180);
    final scanner = _Scanner();
    await _till(tester, scanner);
    await _scanNow(tester, scanner);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a phone, a scan with the cart sheet open shows in the cart at once', (tester) async {
    _size(tester, const Size(390, 844));
    final scanner = _Scanner();
    final container = await _till(tester, scanner);
    await _scanNow(tester, scanner);
    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();
    await _scanNow(tester, scanner);
    expect(container.read(posCartProvider).single.qtyMinor, 2);
  });

  testWidgets('the payment refuses an amount that is not one, and charges nothing', (tester) async {
    _size(tester, const Size(1280, 800));
    final scanner = _Scanner();
    final container = await _till(tester, scanner);
    await _scanNow(tester, scanner);
    await tester.tap(find.byIcon(Icons.point_of_sale));
    await tester.pumpAndSettle();
    await tester.enterText(_inDialog(find.byType(TextField)).first, '12abc');
    await tester.pumpAndSettle();
    expect(_inDialog(find.text(en.errAmountInvalid)), findsOneWidget);
    final charge = _inDialog(find.widgetWithText(FilledButton, en.charge));
    expect(tester.widget<FilledButton>(charge).onPressed, isNull);
    await tester.tap(find.text(en.cancel));
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider), hasLength(1)); // nothing was sold
  });
}

