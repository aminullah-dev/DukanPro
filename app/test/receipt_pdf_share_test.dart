// A customer who wants the receipt on their phone gets it as a PDF: the same
// picture the printer draws, handed to the share sheet from the receipt.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/catalog/catalog_providers.dart';
import 'package:dukanpro/features/pos/pos_screen.dart';
import 'package:dukanpro/infrastructure/file_share.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _piece = '00000000-0000-7000-8000-000000000001';
final en = lookupAppLocalizations(const Locale('en'));

class _Scanner implements BarcodeScanner {
  final controller = StreamController<ScanEvent>.broadcast();
  @override
  Stream<ScanEvent> scans() => controller.stream;
}

SessionActor _cashier() => SessionActor(
      User(
        id: 'u1', username: 'cashier', displayName: 'Cashier', status: UserStatus.active,
        assignments: [BranchAssignment(branchId: 'B1', roleName: 'cashier')], defaultBranchId: 'B1',
      ),
      'B1',
    );

void main() {
  testWidgets('a receipt goes to the share sheet as a PDF of the printed picture', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final dir = Directory.systemTemp.createTempSync('dukan_receipt_pdf');
    addTearDown(() => dir.deleteSync(recursive: true));
    // One from an earlier sale, already sent on.
    File('${dir.path}/dukanpro-receipt-INV-old.pdf').writeAsStringSync('old');
    final sent = <({String path, String mimeType, List<int> bytes})>[];

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final scanner = _Scanner();
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      sessionActorProvider.overrideWithValue(_cashier()),
      deviceIdProvider.overrideWithValue('d1'),
      scannerProvider.overrideWithValue(scanner),
      workDirectoryProvider.overrideWithValue(() async => dir),
      shareFileProvider.overrideWithValue((path, {required mimeType, Rect? origin}) async {
        sent.add((path: path, mimeType: mimeType, bytes: File(path).readAsBytesSync()));
        return true;
      }),
    ]);
    addTearDown(container.dispose);
    final catalog = container.read(localCatalogProvider);
    final soap = Product(id: newId(), sku: 'S1', name: 'Soap', unitId: _piece, sellPrice: Money(5000, 'AFN'));
    await catalog.createProduct(soap, barcodes: [Barcode(id: newId(), productId: soap.id, code: '111')], actorId: 'u1', deviceId: 'd1');
    await catalog.adjust(productId: soap.id, branchId: 'B1', qtyDelta: 10, actorId: 'u1', deviceId: 'd1');
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
    scanner.controller.add(const ScanEvent('111', 'ean13'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.point_of_sale));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.widgetWithText(FilledButton, en.charge)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.shareReceiptPdf));
    // Drawing and compressing are real work, off the test's clock.
    for (var i = 0; i < 250 && sent.isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    final pdf = sent.single;
    expect(pdf.mimeType, 'application/pdf');
    expect(pdf.path, matches(RegExp(r'dukanpro-receipt-[A-Za-z0-9-]+\.pdf$')));
    expect(latin1.decode(pdf.bytes), startsWith('%PDF-1.4'));
    expect(File('${dir.path}/dukanpro-receipt-INV-old.pdf').existsSync(), isFalse, reason: 'only the newest is kept');
    expect(find.text(en.receiptPdfFailed), findsNothing);
  });
}
