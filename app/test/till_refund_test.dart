// Goods come back at the till with or without a connection: the dialog shows
// what they are worth, refuses more than is left, and writes the return here.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:dukanpro/features/pos/return_sale.dart';
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

/// A till with a cash sale of three soaps into an open drawer.
Future<(AppDatabase, LocalSales, SaleRow, Product, String)> _till() async {
  final db = AppDatabase(NativeDatabase.memory());
  final product = Product(
    id: newId(), sku: 'S1', name: 'Soap', unitId: _piece, sellPrice: Money(5000, 'AFN'),
  );
  await LocalCatalog(db).createProduct(product, actorId: 'u1', deviceId: 'd1');
  await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
        id: newId(), productId: product.id, branchId: 'B1', qtyDelta: 10, reason: 'adjustment',
        createdBy: const Value('u1'),
      ));
  final shift = await LocalShifts(db).open(
    branchId: 'B1', userId: 'u1', openingFloatMinor: 0, deviceId: 'd1',
  );
  final sales = LocalSales(db);
  final sale = await sales.settleCash(
    lines: [
      SaleLine(
        productId: product.id, name: product.name, qtyMinor: 3, decimalPlaces: 0,
        unitPriceMinor: 5000, unitCostMinor: 0, currency: 'AFN',
      ),
    ],
    tenderedMinor: 15000, branchId: 'B1', actorId: 'u1', deviceId: 'd1', shiftId: shift.id,
  );
  return (db, sales, sale, product, shift.id);
}

Future<int> _onHand(AppDatabase db, String productId) async {
  final rows = await (db.select(db.stockMovements)
        ..where((t) => t.productId.equals(productId) & t.deletedAt.isNull()))
      .get();
  return rows.fold<int>(0, (sum, m) => sum + m.qtyDelta);
}

void main() {
  testWidgets('the dialog shows the worth, refuses more than is left, and writes the return',
      (tester) async {
    final (db, sales, sale, product, shift) = (await tester.runAsync(_till))!;
    addTearDown(db.close);
    final lines = (await tester.runAsync(() => sales.saleLinesFor(sale.id)))!;
    final returnable = (await tester.runAsync(() => sales.returnable(sale.id)))!;
    RefundDone? result;

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        deviceIdProvider.overrideWithValue('d1'),
        sessionActorProvider.overrideWithValue(_actor('manager')),
        tillRefundProvider.overrideWithValue(TillRefund(
          sales: sales, actorId: 'u1', deviceId: 'd1', openShift: () async => shift,
        )),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showDialog<RefundDone>(
                context: context,
                builder: (_) => ReturnDialog(
                  sale: sale, lines: lines, returnable: returnable, earlierReturnsMinor: 0,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final take = find.widgetWithText(FilledButton, 'Take back');

    await tester.enterText(find.byType(TextField).first, '4');
    await tester.pump();
    expect(find.text('That is more than is left to take back.'), findsOneWidget);
    expect(tester.widget<FilledButton>(take).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pump();
    expect(find.textContaining('50.00'), findsOneWidget); // one soap's worth
    await tester.enterText(find.widgetWithText(TextField, 'Reason'), 'torn wrapper');
    await tester.pump();
    await tester.tap(take);
    await tester.pumpAndSettle();

    expect(result?.moneyBackMinor, 5000);
    final refunds = (await tester.runAsync(() => sales.returnsOf(sale.id)))!;
    expect(refunds.single.totalMinor, -5000);
    expect(await tester.runAsync(() => _onHand(db, product.id)), 8);
    expect(await tester.runAsync(() => sales.returnable(sale.id)), {product.id: 2});
  });

  testWidgets('a cashier does not take goods back', (tester) async {
    final (db, sales, sale, _, _) = (await tester.runAsync(_till))!;
    addTearDown(db.close);
    final lines = (await tester.runAsync(() => sales.saleLinesFor(sale.id)))!;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sessionActorProvider.overrideWithValue(_actor('cashier')),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReturnItemsButton(sale: sale, lines: lines, settled: true, onReturned: (_) {}),
        ),
      ),
    ));
    expect(find.text('Return items'), findsNothing);
  });
}
