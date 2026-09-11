import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

SaleLine _line(String pid) => SaleLine(
      productId: pid, name: 'Soap', qtyMinor: 1, decimalPlaces: 0,
      unitPriceMinor: 52000, unitCostMinor: 40000, currency: 'AFN',
    );

void main() {
  test('dashboard aggregates today sales, profit, debt, and top sellers', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final catalog = LocalCatalog(db);
    final sales = LocalSales(db);
    final customers = LocalCustomers(db);
    final reports = LocalReports(db);

    final p = Product(
      id: newId(), sku: 'P1', name: 'Soap', unitId: 'piece',
      sellPrice: Money(52000, 'AFN'), cost: Money(40000, 'AFN'),
    );
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    await catalog.adjust(productId: p.id, branchId: 'B1', qtyDelta: 40, actorId: 'u1', deviceId: 'app');

    // Cash sale of 2.
    await sales.settleCash(
      lines: [SaleLine(productId: p.id, name: 'Soap', qtyMinor: 2, decimalPlaces: 0, unitPriceMinor: 52000, unitCostMinor: 40000, currency: 'AFN')],
      tenderedMinor: 104000, branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    // Credit sale of 1.
    final c = Customer(id: newId(), name: 'Karim', creditLimitMinor: 200000);
    await customers.createCustomer(c, actorId: 'u1', deviceId: 'app');
    await sales.settle(
      lines: [_line(p.id)], cashMinor: 0, customerId: c.id, customerCreditLimitMinor: 200000,
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );

    final d = await reports.dashboard('B1');
    expect(d.salesTodayMinor, 104000 + 52000);
    expect(d.profitTodayMinor, (52000 - 40000) * 3);
    expect(d.outstandingDebtMinor, 52000);
    expect(d.topSellers.first.name, 'Soap');
    expect(d.topSellers.first.qtyMinor, 3);
  });
}
