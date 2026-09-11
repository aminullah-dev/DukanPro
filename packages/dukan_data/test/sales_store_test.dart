import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

SaleLine _line(String pid, int price, int qty) => SaleLine(
      productId: pid, name: 'Soap', qtyMinor: qty, decimalPlaces: 0,
      unitPriceMinor: price, unitCostMinor: 0, currency: 'AFN',
    );

void main() {
  late AppDatabase db;
  late LocalCatalog catalog;
  late LocalSales sales;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    catalog = LocalCatalog(db);
    sales = LocalSales(db);
  });
  tearDown(() async => db.close());

  test('settle cash writes the sale, decrements stock, and enqueues ops', () async {
    final p = Product(id: newId(), sku: 'P1', name: 'Soap', unitId: 'piece', sellPrice: Money(52000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    await catalog.adjust(productId: p.id, branchId: 'B1', qtyDelta: 40, actorId: 'u1', deviceId: 'app');

    final sale = await sales.settleCash(
      lines: [_line(p.id, 52000, 2)], tenderedMinor: 110000, branchId: 'B1',
      actorId: 'u1', deviceId: 'app',
    );
    expect(sale.totalMinor, 104000);
    expect(sale.changeMinor, 6000);
    expect(sale.number.startsWith('INV-'), isTrue);
    expect(await catalog.onHand(p.id, 'B1'), 38);
    expect((await sales.saleLinesFor(sale.id)).length, 1);

    final ops = await DriftSyncOutbox(db).pending();
    expect(ops.where((o) => o.aggregateType == 'sale').length, 1);
    expect(ops.where((o) => o.aggregateType == 'stock_movement').length, 2); // adjust + sale
  });

  test('underpaid cash throws SALE_UNDERPAID', () async {
    final p = Product(id: newId(), sku: 'P2', name: 'Oil', unitId: 'piece', sellPrice: Money(52000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    expect(
      () => sales.settleCash(
        lines: [_line(p.id, 52000, 2)], tenderedMinor: 100000, branchId: 'B1',
        actorId: 'u1', deviceId: 'app',
      ),
      throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'SALE_UNDERPAID')),
    );
  });
}
