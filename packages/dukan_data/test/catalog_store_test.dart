import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late LocalCatalog catalog;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    catalog = LocalCatalog(db);
  });
  tearDown(() async => db.close());

  test('creating a product persists it + its barcode and enqueues an outbox op', () async {
    final product = Product(id: newId(), sku: 'A1', name: 'Rice', unitId: 'kg', sellPrice: Money(52000, 'AFN'));
    final barcode = Barcode(id: newId(), productId: product.id, code: '5001');
    await catalog.createProduct(product, barcodes: [barcode], actorId: 'u1', deviceId: 'd1');

    expect(await catalog.products.skuTaken('A1'), isTrue);
    final found = await catalog.products.findByBarcode('5001');
    expect(found?.name, 'Rice');
    expect(found?.sellPrice, Money(52000, 'AFN'));

    final pending = await DriftSyncOutbox(db).pending();
    expect(pending.length, 1);
    expect(pending.first.aggregateType, 'product');
    expect(pending.first.localSeq, 1);
  });

  test('adjusting stock derives on-hand from the ledger and enqueues ops in order', () async {
    final product = Product(id: newId(), sku: 'A2', name: 'Oil', unitId: 'piece', sellPrice: Money(85000, 'AFN'));
    await catalog.createProduct(product, actorId: 'u1', deviceId: 'd1');
    await catalog.adjust(productId: product.id, branchId: 'B1', qtyDelta: 40, actorId: 'u1', deviceId: 'd1');
    await catalog.adjust(productId: product.id, branchId: 'B1', qtyDelta: -3, actorId: 'u1', deviceId: 'd1');

    expect(await catalog.onHand(product.id, 'B1'), 37);

    final ops = await DriftSyncOutbox(db).pending();
    expect(ops.length, 3); // 1 product create + 2 stock movements
    expect(ops.map((o) => o.localSeq).toList(), [1, 2, 3]);
    expect(ops.where((o) => o.aggregateType == 'stock_movement').length, 2);
  });

  test('listUnits seeds defaults and is idempotent', () async {
    final units = await catalog.listUnits();
    expect(units.map((u) => u.name), containsAll(['piece', 'kg']));
    expect((await catalog.listUnits()).length, units.length);
  });
}
