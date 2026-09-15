// A void at the till works with or without a connection: the till writes it and
// the stock comes back at once. Only sale.void sees it, and a reason is required.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:dukanpro/features/pos/void_sale.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _piece = '00000000-0000-7000-8000-000000000001';

SessionActor _actor(String role) => SessionActor(
      User(
        id: 'u1', username: role, displayName: role, status: UserStatus.active,
        assignments: [BranchAssignment(branchId: 'B1', roleName: role)], defaultBranchId: 'B1',
      ),
      'B1',
    );

/// A till with one soap in stock and a cash sale of three of them.
Future<(AppDatabase, LocalSales, SaleRow, Product)> _till({String? shiftId}) async {
  final db = AppDatabase(NativeDatabase.memory());
  final product = Product(
    id: newId(), sku: 'S1', name: 'Soap', unitId: _piece, sellPrice: Money(5000, 'AFN'),
  );
  await LocalCatalog(db).createProduct(product, actorId: 'u1', deviceId: 'd1');
  await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
        id: newId(), productId: product.id, branchId: 'B1', qtyDelta: 10, reason: 'adjustment',
        createdBy: const Value('u1'),
      ));
  final sales = LocalSales(db);
  final sale = await sales.settleCash(
    lines: [
      SaleLine(
        productId: product.id, name: product.name, qtyMinor: 3, decimalPlaces: 0,
        unitPriceMinor: 5000, unitCostMinor: 0, currency: 'AFN',
      ),
    ],
    tenderedMinor: 15000, branchId: 'B1', actorId: 'u1', deviceId: 'd1', shiftId: shiftId,
  );
  return (db, sales, sale, product);
}

Future<int> _onHand(AppDatabase db, String productId) async {
  final rows = await (db.select(db.stockMovements)
        ..where((t) => t.productId.equals(productId) & t.deletedAt.isNull()))
      .get();
  return rows.fold<int>(0, (sum, m) => sum + m.qtyDelta);
}

Future<void> _pumpButton(WidgetTester tester, AppDatabase db, LocalSales sales, SaleRow sale,
    String role, {required VoidCallback onVoided}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      deviceIdProvider.overrideWithValue('d1'),
      sessionActorProvider.overrideWithValue(_actor(role)),
      tillVoidProvider.overrideWithValue(TillVoid(sales: sales, actorId: 'u1', deviceId: 'd1')),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: VoidSaleButton(saleId: sale.id, settled: true, onVoided: onVoided)),
    ),
  ));
}

void main() {
  testWidgets('a manager voids with a reason, offline, and the stock comes back', (tester) async {
    final (db, sales, sale, product) = (await tester.runAsync(_till))!;
    addTearDown(db.close);
    var voided = false;
    await _pumpButton(tester, db, sales, sale, 'manager', onVoided: () => voided = true);
    await tester.tap(find.text('Void sale'));
    await tester.pumpAndSettle();
    final confirm = find.widgetWithText(FilledButton, 'Void sale');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull); // no reason yet
    await tester.enterText(find.byType(TextField), 'rang up twice');
    await tester.pump();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(voided, isTrue);
    expect(find.text('The sale was voided.'), findsOneWidget);
    final after = await tester.runAsync(() => sales.byId(sale.id));
    expect(after!.status, 'voided');
    expect(await tester.runAsync(() => _onHand(db, product.id)), 10);
  });

  testWidgets('a cashier has no void', (tester) async {
    final (db, sales, sale, _) = (await tester.runAsync(_till))!;
    addTearDown(db.close);
    await _pumpButton(tester, db, sales, sale, 'cashier', onVoided: () {});
    expect(find.text('Void sale'), findsNothing);
  });

  testWidgets('a cash sale whose drawer has closed is not voided, and the till says why',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final shift = (await tester.runAsync(() => LocalShifts(db).open(
          branchId: 'B1', userId: 'u1', openingFloatMinor: 0, deviceId: 'd1',
        )))!;
    final product = Product(
      id: newId(), sku: 'S1', name: 'Soap', unitId: _piece, sellPrice: Money(5000, 'AFN'),
    );
    await tester.runAsync(() async {
      await LocalCatalog(db).createProduct(product, actorId: 'u1', deviceId: 'd1');
      await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
            id: newId(), productId: product.id, branchId: 'B1', qtyDelta: 10, reason: 'adjustment',
            createdBy: const Value('u1'),
          ));
    });
    final sales = LocalSales(db);
    final sale = (await tester.runAsync(() => sales.settleCash(
          lines: [
            SaleLine(
              productId: product.id, name: product.name, qtyMinor: 1, decimalPlaces: 0,
              unitPriceMinor: 5000, unitCostMinor: 0, currency: 'AFN',
            ),
          ],
          tenderedMinor: 5000, branchId: 'B1', actorId: 'u1', deviceId: 'd1', shiftId: shift.id,
        )))!;
    await tester.runAsync(() => LocalShifts(db).close(
          shift, countedCashMinor: 5000, actorId: 'u1', deviceId: 'd1',
        ));

    await _pumpButton(tester, db, sales, sale, 'owner', onVoided: () {});
    await tester.tap(find.text('Void sale'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'customer changed mind');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Void sale'));
    await tester.pumpAndSettle();

    expect(find.textContaining('shift is already closed'), findsOneWidget);
    final unchanged = await tester.runAsync(() => sales.byId(sale.id));
    expect(unchanged!.status, 'settled');
  });
}
