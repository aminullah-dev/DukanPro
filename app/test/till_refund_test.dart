// Goods come back from the till online: the sale is pushed first and the
// return pulled back. The dialog shows what the goods are worth before asking,
// refuses more than is left, and sends what was typed.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:dukanpro/features/pos/return_sale.dart';
import 'package:dukanpro/infrastructure/auth_api.dart';
import 'package:dukanpro/infrastructure/sales_api.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api implements SalesApi {
  final asked = <String>[];

  @override
  Future<void> voidSale(String saleId, {required String reason}) async {}

  @override
  Future<RefundDone> refundSale(
    String saleId, {
    required Map<String, int> lines,
    required String reason,
    required String method,
    String? shiftId,
  }) async {
    asked.add('$saleId $lines $method $reason');
    return const RefundDone(id: 'r1', number: 'INV-2026-00002', totalMinor: 5000, moneyBackMinor: 5000);
  }
}

SessionActor _actor(String role) => SessionActor(
      User(
        id: 'u-$role', username: role, displayName: role, status: UserStatus.active,
        assignments: [BranchAssignment(branchId: 'B1', roleName: role)], defaultBranchId: 'B1',
      ),
      'B1',
    );

/// A sale of three soaps at 50.00, with its lines, read back as the till sees it.
Future<(SaleRow, List<SaleLineRow>)> _sale(AppDatabase db) async {
  final id = newId();
  await db.into(db.sales).insert(SalesCompanion.insert(
        id: id, number: 'INV-2026-00001', branchId: 'B1',
        subtotalMinor: const Value(15000), totalMinor: const Value(15000), paidMinor: const Value(15000),
      ));
  await db.into(db.saleLines).insert(SaleLinesCompanion.insert(
        id: newId(), saleId: id, productId: 'soap', name: 'Soap', qtyMinor: 3,
        unitPriceMinor: 5000, lineTotalMinor: 15000,
      ));
  final sales = LocalSales(db);
  return ((await sales.byId(id))!, await sales.saleLinesFor(id));
}

void main() {
  test('the sale is pushed, the goods taken back, and the return pulled back', () async {
    final api = _Api();
    var syncs = 0;
    final done = await TillRefund(api: api, sync: () async => syncs++, synced: () => true)(
      's1', lines: {'soap': 1}, reason: 'damaged', method: 'cash', shiftId: 'sh1',
    );
    expect((done.totalMinor, syncs), (5000, 2));
    expect(api.asked, ['s1 {soap: 1} cash damaged']);
  });

  test('offline, nothing is asked of the server', () async {
    final api = _Api();
    await expectLater(
      TillRefund(api: api, sync: () async {}, synced: () => false)('s1', lines: {'soap': 1}, reason: 'x', method: 'cash'),
      throwsA(isA<NetworkException>()),
    );
    expect(api.asked, isEmpty);
  });

  testWidgets('the dialog shows the worth, refuses more than is left, and sends what was typed', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final (sale, lines) = (await tester.runAsync(() => _sale(db)))!;
    final api = _Api();
    RefundDone? result;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sessionActorProvider.overrideWithValue(_actor('manager')),
        currentShiftProvider.overrideWith((ref) async => null),
        tillRefundProvider.overrideWithValue(TillRefund(api: api, sync: () async {}, synced: () => true)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showDialog<RefundDone>(
                context: context,
                builder: (_) => ReturnDialog(sale: sale, lines: lines, returnable: const {'soap': 2}, earlierReturnsMinor: -5000),
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

    await tester.enterText(find.byType(TextField).first, '3');
    await tester.pump();
    expect(find.text('That is more than is left to take back.'), findsOneWidget);
    expect(tester.widget<FilledButton>(take).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pump();
    expect(find.textContaining('50.00'), findsOneWidget); // worth one soap
    expect(tester.widget<FilledButton>(take).onPressed, isNull); // no reason yet
    await tester.enterText(find.widgetWithText(TextField, 'Reason'), 'torn wrapper');
    await tester.pump();
    await tester.tap(take);
    await tester.pumpAndSettle();
    expect(api.asked, ['${sale.id} {soap: 1} cash torn wrapper']);
    expect(result?.number, 'INV-2026-00002');
  });

  testWidgets('a cashier does not take goods back', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final (sale, lines) = (await tester.runAsync(() => _sale(db)))!;
    await tester.pumpWidget(ProviderScope(
      overrides: [sessionActorProvider.overrideWithValue(_actor('cashier'))],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ReturnItemsButton(sale: sale, lines: lines, settled: true, onReturned: (_) {})),
      ),
    ));
    expect(find.text('Return items'), findsNothing);
  });
}
