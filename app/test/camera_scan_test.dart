// A barcode the camera reads works like a scanner's at the till: it adds its
// product, finds a UPC-A in whichever length the reader reports, and says so
// when no product has the code. A device with no camera shows no camera button.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/catalog/catalog_providers.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:dukanpro/features/pos/pos_screen.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:dukanpro/widgets/camera_scan_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _piece = '00000000-0000-7000-8000-000000000001';

SessionActor _owner() => SessionActor(
      User(
        id: 'u1', username: 'owner', displayName: 'Owner', status: UserStatus.active,
        assignments: [BranchAssignment(branchId: 'B1', roleName: 'owner')], defaultBranchId: 'B1',
      ),
      'B1',
    );

/// A till with an open shift, selling soap saved under a UPC-A's 12 digits.
Future<ProviderContainer> _till(WidgetTester tester, CameraScan? camera) async {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(() async => db.close());
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    sessionActorProvider.overrideWithValue(_owner()),
    deviceIdProvider.overrideWithValue('d1'),
    cameraScanProvider.overrideWithValue(camera),
  ]);
  addTearDown(container.dispose);
  final soap = Product(id: newId(), sku: 'S1', name: 'Soap', unitId: _piece, sellPrice: Money(5000, 'AFN'));
  await container.read(localCatalogProvider).createProduct(
        soap, barcodes: [Barcode(id: newId(), productId: soap.id, code: '036000291452')], actorId: 'u1', deviceId: 'd1',
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
  testWidgets("a code the camera reads adds its product, in the 13 digits Apple's Vision reports", (tester) async {
    final container = await _till(tester, (_) async => '0036000291452');
    await tester.tap(find.byTooltip('Scan with camera'));
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider).single.product.name, 'Soap');
  });

  testWidgets('a code no product has is said, and nothing is added', (tester) async {
    final container = await _till(tester, (_) async => '5901234123457');
    await tester.tap(find.byTooltip('Scan with camera'));
    await tester.pumpAndSettle();
    expect(find.text('No product has this barcode.'), findsOneWidget);
    expect(container.read(posCartProvider), isEmpty);
  });

  testWidgets('closing the camera without a code changes nothing', (tester) async {
    final container = await _till(tester, (_) async => null);
    await tester.tap(find.byTooltip('Scan with camera'));
    await tester.pumpAndSettle();
    expect(container.read(posCartProvider), isEmpty);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a device without a camera has no camera button', (tester) async {
    await _till(tester, null);
    expect(find.byType(CameraScanButton), findsNothing);
  });
}
