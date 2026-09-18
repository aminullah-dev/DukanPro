// A UPC-A and the EAN-13 written with a zero in front are one product, and
// readers disagree about which they report: whichever a product was saved with,
// it scans from both.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

const _piece = '00000000-0000-7000-8000-000000000001';

void main() {
  late AppDatabase db;
  late LocalCatalog catalog;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    catalog = LocalCatalog(db);
  });
  tearDown(() => db.close());

  Future<Product> product(String name, String code) async {
    final p = Product(id: newId(), sku: name, name: name, unitId: _piece, sellPrice: Money(1000, 'AFN'));
    await catalog.createProduct(
      p, barcodes: [Barcode(id: newId(), productId: p.id, code: code)], actorId: 'u1', deviceId: 'd1',
    );
    return p;
  }

  test("saved with a UPC-A's 12 digits, it scans from a reader that reports 13", () async {
    final soap = await product('Soap', '036000291452');
    expect((await catalog.products.findByBarcode('0036000291452'))?.id, soap.id);
  });

  test('saved as a 13-digit EAN starting with zero, it scans from 12 digits', () async {
    final tea = await product('Tea', '0036000291452');
    expect((await catalog.products.findByBarcode('036000291452'))?.id, tea.id);
  });

  test('when both forms are on products, the code as read wins', () async {
    final a = await product('A', '036000291452');
    final b = await product('B', '0036000291452');
    expect((await catalog.products.findByBarcode('036000291452'))?.id, a.id);
    expect((await catalog.products.findByBarcode('0036000291452'))?.id, b.id);
  });

  test('a code no product has still finds nothing', () async {
    await product('Soap', '036000291452');
    expect(await catalog.products.findByBarcode('5901234123457'), isNull);
  });
}
