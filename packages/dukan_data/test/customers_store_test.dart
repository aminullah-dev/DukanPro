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
      customerCreditLimitMinor: 200000, branchId: 'B1', actorId: 'u1', deviceId: 'app',
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
        customerCreditLimitMinor: 50000, branchId: 'B1', actorId: 'u1', deviceId: 'app',
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
      lines: [ReceiptLine(productId: p.id, qtyMinor: 10, unitCostMinor: 40000)],
      branchId: 'B1', actorId: 'u1', deviceId: 'app',
    );
    expect(await catalog.onHand(p.id, 'B1'), 10);
    expect(await purchasing.supplierBalance(s.id), 400000);
    expect((await catalog.products.findById(p.id))?.cost?.amountMinor, 40000);
  });
}
