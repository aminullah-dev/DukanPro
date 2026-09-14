import 'package:drift/drift.dart' show Value;
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
      lines: [_line(p.id)], tenders: const [], customerId: c.id,
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );

    final d = await reports.dashboard('B1');
    expect(d.salesTodayMinor, 104000 + 52000);
    expect(d.profitTodayMinor, (52000 - 40000) * 3);
    expect(d.outstandingDebtMinor, 52000);
    expect(d.topSellers.first.name, 'Soap');
    expect(d.topSellers.first.qtyMinor, 3);
  });

  test('low stock counts whole units of active products; top sellers rank by revenue', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final catalog = LocalCatalog(db);
    final sales = LocalSales(db);
    final reports = LocalReports(db);
    final units = {for (final u in await catalog.listUnits()) u.name: u.id};
    final rice = Product(id: newId(), sku: 'R1', name: 'Rice', unitId: units['kg']!, sellPrice: Money(8000, 'AFN'));
    final soap = Product(id: newId(), sku: 'S1', name: 'Soap', unitId: units['piece']!, sellPrice: Money(5000, 'AFN'));
    final old = Product(
      id: newId(), sku: 'O1', name: 'Old', unitId: units['piece']!, sellPrice: Money(100, 'AFN'), isActive: false,
    );
    for (final p in [rice, soap, old]) {
      await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    }
    await catalog.adjust(productId: rice.id, branchId: 'B1', qtyDelta: 4000, actorId: 'u1', deviceId: 'app');
    await catalog.adjust(productId: soap.id, branchId: 'B1', qtyDelta: 40, actorId: 'u1', deviceId: 'app');
    // 1.500 kg of rice (120.00) and 3 soaps (150.00).
    await sales.settleCash(
      lines: [
        SaleLine(productId: rice.id, name: 'Rice', qtyMinor: 1500, decimalPlaces: 3, unitPriceMinor: 8000,
            unitCostMinor: 0, currency: 'AFN'),
        SaleLine(productId: soap.id, name: 'Soap', qtyMinor: 3, decimalPlaces: 0, unitPriceMinor: 5000,
            unitCostMinor: 0, currency: 'AFN'),
      ],
      tenderedMinor: 27000, branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );

    final d = await reports.dashboard('B1');
    expect(d.lowStockCount, 1); // 2.5 kg of rice; the inactive product does not count
    expect(d.topSellers.map((s) => (s.name, s.qtyLabel)), [('Soap', '3 piece'), ('Rice', '1.500 kg')]);
  });

  test("today is the branch's business day, not the device's", () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final catalog = LocalCatalog(db);
    final p = Product(id: newId(), sku: 'P1', name: 'Soap', unitId: 'piece', sellPrice: Money(52000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    await catalog.adjust(productId: p.id, branchId: 'B1', qtyDelta: 5, actorId: 'u1', deviceId: 'app');
    final sale = await LocalSales(db).settleCash(
      lines: [SaleLine(productId: p.id, name: 'Soap', qtyMinor: 1, decimalPlaces: 0, unitPriceMinor: 52000, unitCostMinor: 0, currency: 'AFN')],
      tenderedMinor: 52000, branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    // Sold at 19:29 UTC on 11 September: 23:59 in Kabul, still the 11th there.
    await (db.update(db.sales)..where((t) => t.id.equals(sale.id)))
        .write(SalesCompanion(occurredAt: Value(DateTime.utc(2026, 9, 11, 19, 29))));
    final reports = LocalReports(db);
    Future<int> today(DateTime now, {String zone = 'Asia/Kabul'}) async =>
        (await reports.dashboard('B1', zone: zone, now: now)).salesTodayMinor;

    expect(await today(DateTime.utc(2026, 9, 11, 12)), 52000); // 16:30 on the 11th in Kabul
    expect(await today(DateTime.utc(2026, 9, 11, 20, 30)), 0); // 01:00 on the 12th in Kabul
    expect(await today(DateTime.utc(2026, 9, 11, 20, 30), zone: 'UTC'), 52000); // still the 11th in UTC
  });
}
