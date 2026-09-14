// Theme 7c on the device: SKUs and barcodes stay unique, a scan never throws on
// codes synced twice, a barcode can be taken off, an edit is queued with only
// what changed, an untracked product moves no stock, and a supplier is paid
// within what is owed (cash from a shift leaves its drawer).
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

Matcher _code(String c) => throwsA(isA<AppError>().having((e) => e.code, 'code', c));

void main() {
  late AppDatabase db;
  late LocalCatalog catalog;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    catalog = LocalCatalog(db);
  });
  tearDown(() async => db.close());

  Product product(String sku, {bool track = true}) => Product(
        id: newId(), sku: sku, name: sku, unitId: 'piece', sellPrice: Money(5000, 'AFN'), trackStock: track,
      );

  Product edited(Product p, {bool? isActive, bool? trackStock}) => Product(
        id: p.id, sku: p.sku, name: p.name, unitId: p.unitId, sellPrice: p.sellPrice,
        trackStock: trackStock ?? p.trackStock, isActive: isActive ?? p.isActive, version: p.version,
      );

  Future<List<OutboxOp>> queued() => DriftSyncOutbox(db).pending();

  test('SKUs and barcodes are unique, and a barcode taken off frees its code', () async {
    final soap = product('S1');
    await catalog.createProduct(soap,
        barcodes: [Barcode(id: newId(), productId: soap.id, code: '111')], actorId: 'u1', deviceId: 'd1');
    await expectLater(catalog.createProduct(product('S1'), actorId: 'u1', deviceId: 'd1'), _code('PRODUCT_DUPLICATE_SKU'));
    final milk = product('M1');
    await catalog.createProduct(milk, actorId: 'u1', deviceId: 'd1');
    await expectLater(catalog.addBarcode(milk.id, '111', actorId: 'u1', deviceId: 'd1'), _code('BARCODE_DUPLICATE'));
    final [onSoap] = await catalog.products.barcodesFor(soap.id);
    await catalog.removeBarcode(onSoap.id, actorId: 'u1', deviceId: 'd1');
    expect(await catalog.products.findByBarcode('111'), isNull);
    await catalog.addBarcode(milk.id, '111', actorId: 'u1', deviceId: 'd1');
    expect((await catalog.products.findByBarcode('111'))!.id, milk.id);
    final removal = (await queued()).firstWhere((o) => o.aggregateType == 'barcodes' && o.opType == 'update');
    expect(removal.payload, {'deleted': true});
  });

  test('a scan never throws on a code synced twice, and skips inactive products', () async {
    final a = product('A1');
    final b = product('B1');
    await catalog.createProduct(a, actorId: 'u1', deviceId: 'd1');
    await catalog.createProduct(b, actorId: 'u1', deviceId: 'd1');
    // Two rows with one code, as a pull from before codes were unique could leave.
    for (final p in [a, b]) {
      await catalog.products.addBarcode(Barcode(id: newId(), productId: p.id, code: '999'));
    }
    final first = (await catalog.products.findByBarcode('999'))!;
    expect([a.id, b.id], contains(first.id));
    final stored = (await catalog.products.findById(first.id))!;
    await catalog.updateProduct(edited(stored, isActive: false), actorId: 'u1', deviceId: 'd1');
    expect((await catalog.products.findByBarcode('999'))!.id, first.id == a.id ? b.id : a.id);
  });

  test('an edit is queued with only what changed, track-stock included', () async {
    final p = product('T1');
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'd1');
    final stored = (await catalog.products.findById(p.id))!;
    await catalog.updateProduct(stored, actorId: 'u1', deviceId: 'd1'); // nothing changed
    expect((await queued()).where((o) => o.opType == 'update'), isEmpty);
    await catalog.updateProduct(edited(stored, trackStock: false), actorId: 'u1', deviceId: 'd1');
    final edit = (await queued()).last;
    expect(edit.opType, 'update');
    expect(edit.payload, {'track_stock': false});
    expect((await catalog.products.findById(p.id))!.trackStock, isFalse);
  });

  test('an untracked product moves no stock on any path', () async {
    final service = product('SV', track: false);
    await catalog.createProduct(service, actorId: 'u1', deviceId: 'd1');
    await expectLater(
      catalog.adjust(productId: service.id, branchId: 'B1', qtyDelta: 5, actorId: 'u1', deviceId: 'd1'),
      _code('PRODUCT_NOT_STOCK_TRACKED'),
    );
    await LocalSales(db).settleCash(
      lines: [
        SaleLine(
          productId: service.id, name: 'SV', qtyMinor: 2, decimalPlaces: 0, unitPriceMinor: 5000,
          unitCostMinor: 0, currency: 'AFN', trackStock: false,
        ),
      ],
      tenderedMinor: 10000, branchId: 'B1', actorId: 'u1', deviceId: 'd1',
    );
    await LocalPurchasing(db).receiveGoods(
      lines: [ReceiptLine(productId: service.id, qtyMinor: 3, unitCostMinor: 1000, decimalPlaces: 0)],
      branchId: 'B1', actorId: 'u1', deviceId: 'd1',
    );
    expect(await db.select(db.stockMovements).get(), isEmpty);
  });

  test('a supplier is paid within what is owed; cash from a shift leaves its drawer', () async {
    final purchasing = LocalPurchasing(db);
    final s = Supplier(id: newId(), name: 'Wholesaler');
    await purchasing.createSupplier(s, actorId: 'u1', deviceId: 'd1');
    final p = product('R1');
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'd1');
    await purchasing.receiveGoods(
      supplierId: s.id,
      lines: [ReceiptLine(productId: p.id, qtyMinor: 10, unitCostMinor: 400, decimalPlaces: 0)],
      branchId: 'B1', actorId: 'u1', deviceId: 'd1',
    ); // owes 40.00
    final shifts = LocalShifts(db);
    final shift = await shifts.open(branchId: 'B1', userId: 'u1', openingFloatMinor: 10000, deviceId: 'd1');
    await expectLater(
      purchasing.paySupplier(supplier: s, amountMinor: 5000, actorId: 'u1', deviceId: 'd1'),
      _code('SUPPLIER_OVERPAYMENT'),
    );
    await purchasing.paySupplier(supplier: s, amountMinor: 1500, shiftId: shift.id, actorId: 'u1', deviceId: 'd1');
    expect(await purchasing.supplierBalance(s.id), 2500);
    expect((await shifts.summary(shift)).expectedCashMinor, 10000 - 1500);
  });
}
