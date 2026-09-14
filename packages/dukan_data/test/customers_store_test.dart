import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

SaleLine _line(String pid, int price, int qty) => SaleLine(
      productId: pid, name: 'Item', qtyMinor: qty, decimalPlaces: 0,
      unitPriceMinor: price, unitCostMinor: 0, currency: 'AFN',
    );

void main() {
  late AppDatabase db;
  late LocalCatalog catalog;
  late LocalSales sales;
  late LocalCustomers customers;
  late LocalPurchasing purchasing;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    catalog = LocalCatalog(db);
    sales = LocalSales(db);
    customers = LocalCustomers(db);
    purchasing = LocalPurchasing(db);
  });
  tearDown(() async => db.close());

  test('credit sale posts to the ledger; a payment reduces the balance', () async {
    final p = Product(id: newId(), sku: 'P1', name: 'Soap', unitId: 'piece', sellPrice: Money(52000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    await catalog.adjust(productId: p.id, branchId: 'B1', qtyDelta: 40, actorId: 'u1', deviceId: 'app');
    final c = Customer(id: newId(), name: 'Karim', creditLimitMinor: 200000);
    await customers.createCustomer(c, actorId: 'u1', deviceId: 'app');

    await sales.settle(
      lines: [_line(p.id, 52000, 2)], cashMinor: 0, customerId: c.id,
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    expect(await customers.balance(c.id), 104000);
    expect(await catalog.onHand(p.id, 'B1'), 38);

    await customers.recordPayment(customerId: c.id, amountMinor: 50000, actorId: 'u1', deviceId: 'app');
    expect(await customers.balance(c.id), 54000);
  });

  test('credit over the limit throws SALE_OVER_CREDIT_LIMIT', () async {
    final p = Product(id: newId(), sku: 'P2', name: 'Oil', unitId: 'piece', sellPrice: Money(52000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    final c = Customer(id: newId(), name: 'Ali', creditLimitMinor: 50000);
    await customers.createCustomer(c, actorId: 'u1', deviceId: 'app');
    expect(
      () => sales.settle(
        lines: [_line(p.id, 52000, 2)], cashMinor: 0, customerId: c.id,
        branchId: 'B1', actorId: 'u1', deviceId: 'app',
      ),
      throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'SALE_OVER_CREDIT_LIMIT')),
    );
  });

  test('goods receipt raises stock, supplier balance, and product cost', () async {
    final p = Product(id: newId(), sku: 'P3', name: 'Rice', unitId: 'piece', sellPrice: Money(60000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    final s = Supplier(id: newId(), name: 'Wholesaler');
    await purchasing.createSupplier(s, actorId: 'u1', deviceId: 'app');
    await purchasing.receiveGoods(
      supplierId: s.id,
      lines: [ReceiptLine(productId: p.id, qtyMinor: 10, unitCostMinor: 40000, decimalPlaces: 0)],
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    expect(await catalog.onHand(p.id, 'B1'), 10);
    expect(await purchasing.supplierBalance(s.id), 400000);
    expect((await catalog.products.findById(p.id))?.cost?.amountMinor, 40000);
  });

  test('a zero-cost receipt adds stock but bills the supplier nothing', () async {
    final p = Product(id: newId(), sku: 'P4', name: 'Salt', unitId: 'piece', sellPrice: Money(1000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    final s = Supplier(id: newId(), name: 'Donor');
    await purchasing.createSupplier(s, actorId: 'u1', deviceId: 'app');
    await purchasing.receiveGoods(
      supplierId: s.id,
      lines: [ReceiptLine(productId: p.id, qtyMinor: 5, unitCostMinor: 0, decimalPlaces: 0)],
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    expect(await catalog.onHand(p.id, 'B1'), 5);
    expect(await purchasing.supplierBalance(s.id), 0);
    final ops = await DriftSyncOutbox(db).pending();
    expect(ops.where((o) => o.aggregateType == 'supplier_ledger'), isEmpty); // the server rejects a zero bill
  });

  test('a credit limit change is saved and queued against the version it read', () async {
    final c = Customer(id: newId(), name: 'Ahmad', creditLimitMinor: 0);
    await customers.createCustomer(c, actorId: 'u1', deviceId: 'app');
    final saved = (await customers.find(c.id))!;
    await customers.setCreditLimit(saved, 500000, actorId: 'm1', deviceId: 'app');

    expect((await customers.find(c.id))?.creditLimitMinor, 500000);
    final op = (await DriftSyncOutbox(db).pending()).last;
    expect((op.aggregateType, op.opType, op.baseVersion), ('customers', 'update', saved.version));
    expect(op.payload, {'credit_limit_minor': 500000});
    await expectLater(
      customers.setCreditLimit(saved, -1, actorId: 'm1', deviceId: 'app'),
      throwsA(isA<ValidationError>()),
    );
  });

  test('a receipt without a cost keeps the product cost', () async {
    final p = Product(
      id: newId(), sku: 'P5', name: 'Oil', unitId: 'piece',
      sellPrice: Money(9000, 'AFN'), cost: Money(7000, 'AFN'),
    );
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    await purchasing.receiveGoods(
      lines: [ReceiptLine(productId: p.id, qtyMinor: 3, unitCostMinor: 0, decimalPlaces: 0)],
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    expect(await catalog.onHand(p.id, 'B1'), 3);
    expect((await catalog.products.findById(p.id))?.cost?.amountMinor, 7000);
  });

  test('money inputs are checked before anything is written', () async {
    final p = Product(id: newId(), sku: 'P9', name: 'Tea', unitId: 'piece', sellPrice: Money(5000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    final c = Customer(id: newId(), name: 'Karim');
    await customers.createCustomer(c, actorId: 'u1', deviceId: 'app');
    final before = (await DriftSyncOutbox(db).pending()).length;
    Matcher code(String c) => throwsA(isA<AppError>().having((e) => e.code, 'code', c));

    Future<SaleRow> credit(int qty, int cash) => sales.settle(
          lines: [_line(p.id, 5000, qty)], cashMinor: cash, customerId: c.id,
          branchId: 'B1', actorId: 'u1', deviceId: 'app',
        );
    await expectLater(credit(1, -100), code('SALE_PAYMENT_INVALID'));
    await expectLater(credit(1, 6000), code('SALE_OVERPAID'));
    await expectLater(credit(0, 0), code('SALE_LINE_INVALID_QTY'));
    await expectLater(
      customers.recordPayment(customerId: c.id, amountMinor: 0, actorId: 'u1', deviceId: 'app'),
      code('DEBT_PAYMENT_INVALID'),
    );
    await expectLater(
      purchasing.receiveGoods(
        lines: [ReceiptLine(productId: p.id, qtyMinor: -5, unitCostMinor: 100, decimalPlaces: 0)],
        branchId: 'B1', actorId: 'u1', deviceId: 'app',
      ),
      code('GRN_LINE_INVALID'),
    );
    await expectLater(
      catalog.createProduct(
        Product(id: newId(), sku: 'NEG', name: 'Neg', unitId: 'piece', sellPrice: Money(-1, 'AFN')),
        actorId: 'u1', deviceId: 'app',
      ),
      code('CATALOG_PRICE_INVALID'),
    );
    expect((await DriftSyncOutbox(db).pending()).length, before);
  });

  test('a kg receipt bills the supplier for the weight, not the grams', () async {
    final units = {for (final u in await catalog.listUnits()) u.name: u.id};
    final p = Product(id: newId(), sku: 'RICE', name: 'Rice', unitId: units['kg']!, sellPrice: Money(8000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    final s = Supplier(id: newId(), name: 'Wholesaler');
    await purchasing.createSupplier(s, actorId: 'u1', deviceId: 'app');
    await purchasing.receiveGoods(
      supplierId: s.id,
      lines: [ReceiptLine(productId: p.id, qtyMinor: 2500, unitCostMinor: 4000, decimalPlaces: 3)],
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    expect(await catalog.onHand(p.id, 'B1'), 2500);
    expect(await purchasing.supplierBalance(s.id), 10000); // 2.500 kg at 40.00 is 100.00
  });

  test('a received cost is queued as a product edit against the version it read', () async {
    final p = Product(id: newId(), sku: 'C1', name: 'Oil', unitId: 'piece', sellPrice: Money(9000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    await purchasing.receiveGoods(
      lines: [ReceiptLine(productId: p.id, qtyMinor: 2, unitCostMinor: 7000, decimalPlaces: 0)],
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    final edit = (await DriftSyncOutbox(db).pending())
        .singleWhere((o) => o.aggregateType == 'products' && o.opType == 'update');
    expect(edit.payload, {'cost_minor': 7000});
    expect(edit.baseVersion, 1);
    expect((await catalog.products.findById(p.id))!.version, 2);
  });

  test('sale numbers carry the device, so two tills never issue the same one', () async {
    final p = Product(id: newId(), sku: 'N1', name: 'Pen', unitId: 'piece', sellPrice: Money(1000, 'AFN'));
    await catalog.createProduct(p, actorId: 'u1', deviceId: 'app');
    Future<String> sell(String device) async => (await sales.settleCash(
          lines: [_line(p.id, 1000, 1)], tenderedMinor: 1000, branchId: 'B1', actorId: 'u1', deviceId: device,
        ))
            .number;
    final a1 = await sell('0190f0e0-aaaa-7000-8000-00000000a1b2');
    final a2 = await sell('0190f0e0-aaaa-7000-8000-00000000a1b2');
    final b1 = await sell('0190f0e0-bbbb-7000-8000-00000000c3d4');
    expect({a1, a2, b1}, hasLength(3));
    expect(a1, matches(RegExp(r'^INV-00A1B2-\d{8}-0001$')));
    expect(a2, endsWith('-0002'));
    expect(b1, matches(RegExp(r'^INV-00C3D4-\d{8}-0001$')));
  });
}
