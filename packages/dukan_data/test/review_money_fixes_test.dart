// Review of themes 6-9, money: each till sells into its own shift, a single
// till sells no more than it holds, and a mistyped SKU can be corrected.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

SaleLine _line(Product p, int qty) => SaleLine(
      productId: p.id, name: p.name, qtyMinor: qty, decimalPlaces: 0,
      unitPriceMinor: p.sellPrice.amountMinor, unitCostMinor: 0, currency: 'AFN',
    );

void main() {
  test("a till's current shift is the one it opened, not one pulled from another till", () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final shifts = LocalShifts(db);
    final mine = await shifts.open(branchId: 'B1', userId: 'u1', openingFloatMinor: 0, deviceId: 'd1');
    // The same seller's drawer on another till, pulled later (no outbox op here).
    final theirs = newId();
    await db.into(db.shifts).insert(ShiftsCompanion.insert(
          id: theirs, branchId: 'B1', userId: 'u1', openedAt: Value(DateTime.now().toUtc().add(const Duration(minutes: 5))),
        ));
    expect((await shifts.current(branchId: 'B1', userId: 'u1', deviceId: 'd1'))?.id, mine.id);
    expect((await shifts.current(branchId: 'B1', userId: 'u1', deviceId: 'd2')), isNull);
    expect((await shifts.current(branchId: 'B1', userId: 'u1'))?.id, theirs); // any drawer: the newest
  });

  test('a single till sells no more of a tracked product than it holds', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = LocalCatalog(db);
    final soap = Product(id: newId(), sku: 'S1', name: 'Soap', unitId: 'piece', sellPrice: Money(5000, 'AFN'));
    await catalog.createProduct(soap, actorId: 'u1', deviceId: 'd1');
    await catalog.adjust(productId: soap.id, branchId: 'B1', qtyDelta: 2, actorId: 'u1', deviceId: 'd1');
    final sales = LocalSales(db);
    await expectLater(
      sales.settleCash(lines: [_line(soap, 2), _line(soap, 1)], tenderedMinor: 15000, branchId: 'B1', actorId: 'u1', deviceId: 'd1'),
      throwsA(isA<ConflictError>()
          .having((e) => e.code, 'code', 'STOCK_INSUFFICIENT')
          .having((e) => e.context['sku'], 'sku', 'S1')),
    );
    await sales.settleCash(lines: [_line(soap, 2)], tenderedMinor: 10000, branchId: 'B1', actorId: 'u1', deviceId: 'd1');
    expect(await catalog.onHand(soap.id, 'B1'), 0);
    // An untracked product (a service) has no stock to run out of.
    final repair = Product(
      id: newId(), sku: 'R1', name: 'Repair', unitId: 'piece', sellPrice: Money(5000, 'AFN'), trackStock: false,
    );
    await catalog.createProduct(repair, actorId: 'u1', deviceId: 'd1');
    final untracked = SaleLine(
      productId: repair.id, name: 'Repair', qtyMinor: 1, decimalPlaces: 0, unitPriceMinor: 5000,
      unitCostMinor: 0, currency: 'AFN', trackStock: false,
    );
    await sales.settleCash(lines: [untracked], tenderedMinor: 5000, branchId: 'B1', actorId: 'u1', deviceId: 'd1');
  });

  test('a mistyped SKU is corrected, and another product\'s SKU is refused', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = LocalCatalog(db);
    final a = Product(id: newId(), sku: 'RIC1', name: 'Rice', unitId: 'kg', sellPrice: Money(5000, 'AFN'));
    final b = Product(id: newId(), sku: 'SUG1', name: 'Sugar', unitId: 'kg', sellPrice: Money(6000, 'AFN'));
    await catalog.createProduct(a, actorId: 'u1', deviceId: 'd1');
    await catalog.createProduct(b, actorId: 'u1', deviceId: 'd1');
    Product withSku(Product p, String sku) =>
        Product(id: p.id, sku: sku, name: p.name, unitId: p.unitId, sellPrice: p.sellPrice, version: p.version);
    await catalog.updateProduct(withSku(a, 'RICE1'), actorId: 'u1', deviceId: 'd1');
    expect((await catalog.products.findById(a.id))!.sku, 'RICE1');
    final ops = await DriftSyncOutbox(db).pending();
    expect(ops.last.payload, {'sku': 'RICE1'}); // only what changed
    final current = (await catalog.products.findById(a.id))!;
    await expectLater(
      catalog.updateProduct(withSku(current, 'SUG1'), actorId: 'u1', deviceId: 'd1'),
      throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'PRODUCT_DUPLICATE_SKU')),
    );
  });
}
