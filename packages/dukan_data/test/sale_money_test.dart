// Theme 7a on the device: credit follows the customer's own row (open, their
// currency, their limit), a write-off is a signed adjustment within the
// balance, closing an account is a versioned edit, and profit is what the
// sales took less what the goods cost.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

SaleLine _line(String productId, {int qty = 1, int cost = 0}) => SaleLine(
      productId: productId, name: 'Soap', qtyMinor: qty, decimalPlaces: 0,
      unitPriceMinor: 52000, unitCostMinor: cost, currency: 'AFN',
    );

Matcher _code(String c) => throwsA(isA<AppError>().having((e) => e.code, 'code', c));

void main() {
  late AppDatabase db;
  late LocalSales sales;
  late LocalCustomers customers;
  late String soap;
  late String tea;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    sales = LocalSales(db);
    customers = LocalCustomers(db);
    final catalog = LocalCatalog(db);
    soap = newId();
    tea = newId();
    for (final (id, sku) in [(soap, 'S1'), (tea, 'T1')]) {
      await catalog.createProduct(
        Product(id: id, sku: sku, name: sku, unitId: 'piece', sellPrice: Money(52000, 'AFN')),
        actorId: 'u1', deviceId: 'd1',
      );
    }
  });
  tearDown(() async => db.close());

  Future<Customer> customer({int? limit, String currency = 'AFN'}) async {
    final c = Customer(id: newId(), name: 'Karim', creditLimitMinor: limit, currency: currency);
    await customers.createCustomer(c, actorId: 'u1', deviceId: 'd1');
    return (await customers.find(c.id))!;
  }

  Future<SaleRow> onCredit(Customer c, {int qty = 1}) => sales.settle(
        lines: [_line(soap, qty: qty)], cashMinor: 0, customerId: c.id,
        branchId: 'B1', actorId: 'u1', deviceId: 'd1',
      );

  test("credit follows the customer's own row: open, their currency, their limit", () async {
    final karim = await customer(limit: 60000);
    await onCredit(karim); // 520.00, within 600.00
    await expectLater(onCredit(karim), _code('SALE_OVER_CREDIT_LIMIT'));
    await customers.setActive(karim, false, actorId: 'u1', deviceId: 'd1');
    final closed = (await customers.find(karim.id))!;
    expect(closed.isActive, isFalse);
    expect(closed.version, karim.version + 1);
    await expectLater(onCredit(closed), _code('CUSTOMER_INACTIVE'));
    await expectLater(onCredit(await customer(currency: 'USD')), _code('DEBT_CURRENCY_MISMATCH'));
  });

  test('a write-off lowers the debt and is queued as a signed adjustment', () async {
    final karim = await customer();
    await onCredit(karim, qty: 2); // owes 1040.00
    await expectLater(
      customers.writeOff(customer: karim, amountMinor: 200000, actorId: 'u1', deviceId: 'd1'),
      _code('DEBT_WRITE_OFF_EXCEEDS_BALANCE'),
    );
    await customers.writeOff(customer: karim, amountMinor: 40000, actorId: 'u1', deviceId: 'd1');
    expect(await customers.balance(karim.id), 64000);
    final op = (await DriftSyncOutbox(db).pending()).last;
    expect(op.aggregateType, 'customer_ledger');
    expect(op.payload, containsPair('amount_minor', -40000));
    expect(op.payload, containsPair('ref_type', 'write_off'));
  });

  test('closing an account is queued as a customer edit', () async {
    final karim = await customer();
    await customers.setActive(karim, false, actorId: 'u1', deviceId: 'd1');
    final op = (await DriftSyncOutbox(db).pending()).last;
    expect(op.aggregateType, 'customers');
    expect(op.opType, 'update');
    expect(op.payload, {'is_active': false});
  });

  test('profit is what the sales took, less what the goods cost', () async {
    // 2 soaps at a 400.00 cost and a tea with no cost, less a 100.00 discount.
    await sales.settle(
      lines: [_line(soap, qty: 2, cost: 40000), _line(tea)],
      discountMinor: 10000, cashMinor: 146000, tenderedMinor: 146000,
      branchId: 'B1', actorId: 'u1', deviceId: 'd1',
    );
    final d = await LocalReports(db).dashboard('B1');
    expect(d.salesTodayMinor, 146000);
    expect(d.profitTodayMinor, 146000 - 80000);
    expect(d.unknownCostLines, 1);
  });
}
