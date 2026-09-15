// Theme 8: the receive screen as a pane of the shell (nothing to go back to)
// clears itself for the next delivery instead of popping the only page.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/catalog/catalog_providers.dart';
import 'package:dukanpro/features/purchasing/receive_stock_screen.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a receipt in a pane clears the form and says so', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      sessionActorProvider.overrideWithValue(SessionActor(
        User(
          id: 'u1', username: 'owner', displayName: 'Owner', status: UserStatus.active,
          assignments: [BranchAssignment(branchId: 'B1', roleName: 'owner')], defaultBranchId: 'B1',
        ),
        'B1',
      )),
    ]);
    addTearDown(container.dispose);
    final soap = Product(
      id: newId(), sku: 'S1', name: 'Soap', unitId: '00000000-0000-7000-8000-000000000001',
      sellPrice: Money(5000, 'AFN'),
    );
    await container.read(localCatalogProvider).createProduct(soap, actorId: 'u1', deviceId: 'd1');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReceiveStockScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Soa');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soap').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '5');
    await tester.tap(find.text('Receive'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Received into stock'), findsOneWidget);
    expect(find.byType(ReceiveStockScreen), findsOneWidget);
    expect(await container.read(onHandProvider((soap.id, 'B1')).future), 5);
  });
}
