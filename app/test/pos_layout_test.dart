// Theme 8 on the POS: a phone gets the products over a cart bar, and a scan
// never changes a sale while its payment dialog is open.
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

// A fresh event per scan, as the wedge scanner makes them (an identical one would
// read as no change to the provider).
final _ean = 'ean13';
ScanEvent _scan() => ScanEvent('111', _ean);

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

Future<ProviderContainer> _shop(WidgetTester tester, _Scanner scanner) async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(() async => db.close());
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    sessionActorProvider.overrideWithValue(_owner()),
    deviceIdProvider.overrideWithValue('d1'), // the till that opened the shift
    scannerProvider.overrideWithValue(scanner),
  ]);
  addTearDown(container.dispose);
  final soap = Product(id: newId(), sku: 'S1', name: 'Soap', unitId: _piece, sellPrice: Money(5000, 'AFN'));
  await container.read(localCatalogProvider).createProduct(
        soap, barcodes: [Barcode(id: newId(), productId: soap.id, code: '111')], actorId: 'u1', deviceId: 'd1',
      );
  await LocalShifts(db).open(branchId: 'B1', userId: 'u1', openingFloatMinor: 0, deviceId: 'd1');
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

void _size(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('on a phone the products sit over a cart bar, with nothing overflowing', (tester) async {
    _size(tester, const Size(390, 844));
    final container = await _shop(tester, _Scanner());
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    await tester.tap(find.text('Soap'));
    await tester.pump();
    expect(container.read(posCartProvider), hasLength(1));
  });

  testWidgets('a scan while the payment dialog is open does not change the sale', (tester) async {
    _size(tester, const Size(1280, 800));
    final scanner = _Scanner();
    final container = await _shop(tester, scanner);
    scanner.controller.add(_scan());
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.qtyMinor, 1);

    await tester.tap(find.byIcon(Icons.point_of_sale));
    await tester.pumpAndSettle();
    scanner.controller.add(_scan());
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.qtyMinor, 1);

    // Cancelled, the scan made during the payment comes in, and the POS takes
    // scans again.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.qtyMinor, 2);
    scanner.controller.add(_scan());
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.qtyMinor, 3);
  });
}
