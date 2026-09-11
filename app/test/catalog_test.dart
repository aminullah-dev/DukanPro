import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/catalog/catalog_providers.dart';
import 'package:dukanpro/features/catalog/product_list_screen.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Product _rice() =>
    Product(id: newId(), sku: 'A1', name: 'Rice', unitId: 'kg', sellPrice: Money(52000, 'AFN'));

void main() {
  test('a created product surfaces in productsProvider; adjust updates on-hand', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    final catalog = container.read(localCatalogProvider);
    final product = _rice();
    await catalog.createProduct(product, actorId: 'u1', deviceId: 'app');

    final products = await container.read(productsProvider.future);
    expect(products.map((p) => p.sku), contains('A1'));

    await catalog.adjust(productId: product.id, branchId: 'B1', qtyDelta: 40, actorId: 'u1', deviceId: 'app');
    expect(await container.read(onHandProvider((product.id, 'B1')).future), 40);
  });

  testWidgets('product list renders a seeded product', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    await container.read(localCatalogProvider).createProduct(_rice(), actorId: 'u1', deviceId: 'app');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProductListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rice'), findsOneWidget);
  });
}
