import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/catalog/catalog_providers.dart';
import 'package:dukanpro/features/customers/customers_providers.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('credit sale posts to a customer ledger, surfaced via providers; payment reduces it', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(c.dispose);

    final catalog = c.read(localCatalogProvider);
    final customers = c.read(localCustomersProvider);
    final sales = c.read(localSalesProvider);

    final product = Product(id: newId(), sku: 'P1', name: 'Soap', unitId: 'piece', sellPrice: Money(52000, 'AFN'));
    await catalog.createProduct(product, actorId: 'u1', deviceId: 'app');
    final customer = Customer(id: newId(), name: 'Karim', creditLimitMinor: 200000);
    await customers.createCustomer(customer, actorId: 'u1', deviceId: 'app');

    expect((await c.read(customersProvider.future)).map((x) => x.name), contains('Karim'));

    await sales.settle(
      lines: [
        SaleLine(
          productId: product.id, name: 'Soap', qtyMinor: 2, decimalPlaces: 0,
          unitPriceMinor: 52000, unitCostMinor: 0, currency: 'AFN',
        ),
      ],
      cashMinor: 0, customerId: customer.id,
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    expect(await c.read(customerBalanceProvider(customer.id).future), 104000);

    await customers.recordPayment(customerId: customer.id, amountMinor: 50000, actorId: 'u1', deviceId: 'app');
    expect(await customers.balance(customer.id), 54000);
  });
}
