// A scanner types a code's keys into the focused field, and a Dari layout
// turns its letters into Persian ones: the till still takes the scan back out
// and adds the product. Digits line up in either digit system.
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
import 'package:dukanpro/widgets/digits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _piece = '00000000-0000-7000-8000-000000000001';


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
        soap, barcodes: [Barcode(id: newId(), productId: soap.id, code: 'AB12')], actorId: 'u1', deviceId: 'd1',
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

void main() {
  test('what a scanner typed under a Dari or a Latin layout is recognised', () {
    expect(typedByScan('AB12', 'AB12'), isTrue);
    expect(typedByScan('شذ12', 'AB12'), isTrue); // Dari: A and B are ش and ذ
    expect(typedByScan('شذ۱۲', 'AB12'), isTrue); // and Persian digits
    expect(typedByScan('ab12', 'AB12'), isFalse); // a Latin letter is itself
    expect(typedByScan('شذ13', 'AB12'), isFalse); // digits must match
    expect(typedByScan('شذ1', 'AB12'), isFalse);
    expect(endsWithScan('soap شذ12', 'AB12'), isTrue);
    expect(endsWithScan('احمد', 'ABCD', needDigit: true), isFalse); // a Dari name is not a scan
    expect(endsWithScan('احمد شذ12', 'AB12', needDigit: true), isTrue);
  });

  testWidgets('a letter barcode scanned into an empty search under a Dari layout adds its product', (tester) async {
    final scanner = _Scanner();
    final container = await _shop(tester, scanner);
    final search = find.byType(TextField).first;
    await tester.tap(search);
    await tester.enterText(search, 'شذ12'); // the scanner's keys, as the layout typed them
    scanner.controller.add(const ScanEvent('AB12', 'code128'));
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.qtyMinor, 1);
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
  });

  testWidgets('a letter barcode scanned after a typed search keeps the search', (tester) async {
    final scanner = _Scanner();
    final container = await _shop(tester, scanner);
    final search = find.byType(TextField).first;
    await tester.tap(search);
    await tester.enterText(search, 'soapشذ12');
    scanner.controller.add(const ScanEvent('AB12', 'code128'));
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.qtyMinor, 1);
    expect(tester.widget<TextField>(search).controller!.text, 'soap');
  });
}
