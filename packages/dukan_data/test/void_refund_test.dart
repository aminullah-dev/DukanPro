// A till voids a sale and takes goods back with or without a connection: the
// stock comes back, the customer's debt comes off, and every row of it is
// queued in one device transaction (docs/domain/sales.md).
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

const _piece = '00000000-0000-7000-8000-000000000001';

SaleLine _line(Product p, int qty) => SaleLine(
      productId: p.id, name: p.name, qtyMinor: qty, decimalPlaces: 0,
      unitPriceMinor: p.sellPrice.amountMinor, unitCostMinor: 0, currency: 'AFN',
    );

Future<Product> _product(AppDatabase db, {int stock = 10}) async {
  final product = Product(
    id: newId(), sku: 'S${newId().substring(0, 6)}', name: 'Soap', unitId: _piece,
    sellPrice: Money(5000, 'AFN'),
  );
  await LocalCatalog(db).createProduct(product, actorId: 'u1', deviceId: 'd1');
  await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(
        id: newId(), productId: product.id, branchId: 'B1', qtyDelta: stock, reason: 'adjustment',
        createdBy: const Value('u1'),
      ));
  return product;
}

Future<int> _onHand(AppDatabase db, String productId) async {
  final rows = await (db.select(db.stockMovements)
        ..where((t) => t.productId.equals(productId) & t.deletedAt.isNull()))
      .get();
  return rows.fold<int>(0, (sum, m) => sum + m.qtyDelta);
}

/// What the customer owes, by the ledger's own rule (a payment is not a charge
/// with a minus sign).
Future<int> _balance(AppDatabase db, String customerId) => LocalCustomers(db).balance(customerId);

Future<String> _customer(AppDatabase db) async {
  final id = newId();
  await db.into(db.customers).insert(CustomersCompanion.insert(id: id, name: 'Karim'));
  return id;
}

/// The ops queued since [from], newest last.
Future<List<OutboxOp>> _queued(AppDatabase db, int from) async =>
    (await DriftSyncOutbox(db).pending()).sublist(from);

void main() {
  late AppDatabase db;
  late LocalSales sales;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sales = LocalSales(db);
  });
  tearDown(() => db.close());

  test('a void puts the stock back and queues its rows as one transaction', () async {
    final product = await _product(db);
    final sale = await sales.settleCash(
      lines: [_line(product, 3)], tenderedMinor: 15000, branchId: 'B1', actorId: 'u1', deviceId: 'd1',
    );
    expect(await _onHand(db, product.id), 7);
    final before = (await DriftSyncOutbox(db).pending()).length;

    await sales.voidSale(saleId: sale.id, reason: 'rang up twice', actorId: 'u1', deviceId: 'd1');

    expect((await sales.byId(sale.id))!.status, 'voided');
    expect(await _onHand(db, product.id), 10);
    final ops = await _queued(db, before);
    expect(ops.map((o) => '${o.aggregateType}/${o.opType}'), ['sales/update', 'stock_movements/insert']);
    expect(ops.first.payload, {'status': 'voided', 'void_reason': 'rang up twice'});
    expect(ops.last.payload['ref_type'], 'void');
    expect(ops.map((o) => o.txId).toSet(), hasLength(1));
    expect(ops.first.txId, isNotNull);
  });

  test('a void takes back what the customer still owes, not what they paid', () async {
    final product = await _product(db);
    final customer = await _customer(db);
    final sale = await sales.settle(
      lines: [_line(product, 2)], tenders: const [], customerId: customer, branchId: 'B1',
      actorId: 'u1', deviceId: 'd1',
    );
    expect(await _balance(db, customer), 10000);
    // They pay 30.00 of it before the sale is voided.
    await LocalCustomers(db).recordPayment(
      customerId: customer, amountMinor: 3000, actorId: 'u1', deviceId: 'd1',
    );

    await sales.voidSale(saleId: sale.id, reason: 'wrong goods', actorId: 'u1', deviceId: 'd1');

    // 70.00 was still owed and comes off; the 30.00 they paid is handed back by hand.
    expect(await _balance(db, customer), 0);
    expect((await sales.byId(sale.id))!.status, 'voided');
  });

  test('a void says why, happens once, and leaves a closed drawer alone', () async {
    final product = await _product(db);
    final shift = await LocalShifts(db).open(
      branchId: 'B1', userId: 'u1', openingFloatMinor: 0, deviceId: 'd1',
    );
    final sale = await sales.settleCash(
      lines: [_line(product, 1)], tenderedMinor: 5000, branchId: 'B1', actorId: 'u1',
      deviceId: 'd1', shiftId: shift.id,
    );
    await expectLater(
      sales.voidSale(saleId: sale.id, reason: '  ', actorId: 'u1', deviceId: 'd1'),
      throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'SALE_VOID_REASON_REQUIRED')),
    );
    await LocalShifts(db).close(shift, countedCashMinor: 5000, actorId: 'u1', deviceId: 'd1');
    await expectLater(
      sales.voidSale(saleId: sale.id, reason: 'too late', actorId: 'u1', deviceId: 'd1'),
      throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'SALE_SHIFT_CLOSED')),
    );
  });

  test('a return writes a negative sale that names the sale, with the goods and money back', () async {
    final product = await _product(db);
    final shift = await LocalShifts(db).open(
      branchId: 'B1', userId: 'u1', openingFloatMinor: 0, deviceId: 'd1',
    );
    final sale = await sales.settleCash(
      lines: [_line(product, 3)], tenderedMinor: 15000, branchId: 'B1', actorId: 'u1',
      deviceId: 'd1', shiftId: shift.id,
    );
    final before = (await DriftSyncOutbox(db).pending()).length;

    final refund = await sales.refund(
      saleId: sale.id, lines: {product.id: 1}, reason: 'torn wrapper', method: 'cash',
      shiftId: shift.id, actorId: 'u1', deviceId: 'd1',
    );

    expect((refund.refundOf, refund.totalMinor, refund.paidMinor), (sale.id, -5000, -5000));
    expect(await _onHand(db, product.id), 8);
    expect(await sales.returnable(sale.id), {product.id: 2});
    final ops = await _queued(db, before);
    expect(ops.map((o) => o.aggregateType), ['sales', 'sale_lines', 'stock_movements', 'payments']);
    expect(ops.first.payload['refund_of'], sale.id);
    expect(ops.first.payload['refund_reason'], 'torn wrapper');
    expect(ops[1].payload['qty_minor'], -1);
    expect(ops.last.payload['amount_minor'], -5000);
    expect(ops.map((o) => o.txId).toSet(), hasLength(1));
  });

  test('returns take back no more than is left, and the last one takes what is left', () async {
    final product = await _product(db);
    final sale = await sales.settleCash(
      lines: [_line(product, 3)], tenderedMinor: 15000, branchId: 'B1', actorId: 'u1', deviceId: 'd1',
    );
    await sales.refund(
      saleId: sale.id, lines: {product.id: 1}, reason: 'one back', method: 'transfer',
      actorId: 'u1', deviceId: 'd1',
    );
    final rest = await sales.refund(
      saleId: sale.id, lines: {product.id: 2}, reason: 'the rest', method: 'transfer',
      actorId: 'u1', deviceId: 'd1',
    );
    expect(rest.totalMinor, -10000); // the sale's 150.00 came back in full
    expect(await sales.returnable(sale.id), {product.id: 0});
    expect(await _onHand(db, product.id), 10);
    await expectLater(
      sales.refund(
        saleId: sale.id, lines: {product.id: 1}, reason: 'again', method: 'transfer',
        actorId: 'u1', deviceId: 'd1',
      ),
      throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'REFUND_QTY_INVALID')),
    );
    await expectLater(
      sales.voidSale(saleId: sale.id, reason: 'after returns', actorId: 'u1', deviceId: 'd1'),
      throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'SALE_NOT_VOIDABLE')),
    );
  });
}
