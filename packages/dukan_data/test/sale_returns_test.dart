// A return pulled from the server names its sale; the till reads what of each
// product the sale can still take back.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart' show newId;
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

Future<void> _sale(AppDatabase db, String id, {String? refundOf, required Map<String, int> lines}) async {
  await db.into(db.sales).insert(SalesCompanion.insert(
        id: id, number: 'INV-$id', branchId: 'B1', refundOf: Value(refundOf),
      ));
  for (final entry in lines.entries) {
    await db.into(db.saleLines).insert(SaleLinesCompanion.insert(
          id: newId(), saleId: id, productId: entry.key, name: entry.key,
          qtyMinor: entry.value, unitPriceMinor: 5000, lineTotalMinor: 5000 * entry.value,
        ));
  }
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('what a sale can still take back is what it sold less its returns', () async {
    final sales = LocalSales(db);
    final sale = newId(), first = newId(), second = newId();
    await _sale(db, sale, lines: {'soap': 3, 'rice': 2});
    expect(await sales.returnable(sale), {'soap': 3, 'rice': 2});
    expect(await sales.returnsOf(sale), isEmpty);

    await _sale(db, first, refundOf: sale, lines: {'soap': -1});
    await _sale(db, second, refundOf: sale, lines: {'soap': -2, 'rice': -1});
    expect(await sales.returnable(sale), {'soap': 0, 'rice': 1});
    expect((await sales.returnsOf(sale)).map((r) => r.id), unorderedEquals([first, second]));
    expect((await sales.byId(first))?.refundOf, sale);
  });
}
