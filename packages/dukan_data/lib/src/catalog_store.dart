import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart';

import '../database.dart';
import 'sync_recorder.dart';

/// Drift-backed [ProductRepository].
final class ProductDao implements ProductRepository {
  ProductDao(this._db);
  final AppDatabase _db;

  Product _toProduct(ProductRow r) => Product(
        id: r.id,
        sku: r.sku,
        name: r.name,
        unitId: r.unitId,
        sellPrice: Money(r.sellPriceMinor, r.sellCurrency),
        categoryId: r.categoryId,
        cost: r.costMinor != null ? Money(r.costMinor!, r.costCurrency ?? 'AFN') : null,
        trackStock: r.trackStock,
        isActive: r.isActive,
        version: r.version,
      );

  @override
  Future<void> create(Product product, {List<Barcode> barcodes = const []}) async {
    await _db.transaction(() async {
      await _db.into(_db.products).insert(_insertCompanion(product));
      for (final b in barcodes) {
        await _db.into(_db.barcodes).insert(BarcodesCompanion.insert(
              id: b.id, productId: b.productId, code: b.code,
              symbology: Value(b.symbology),
            ));
      }
    });
  }

  ProductsCompanion _insertCompanion(Product p) => ProductsCompanion.insert(
        id: p.id,
        sku: p.sku,
        name: p.name,
        unitId: p.unitId,
        categoryId: Value(p.categoryId),
        sellPriceMinor: Value(p.sellPrice.amountMinor),
        sellCurrency: Value(p.sellPrice.currency),
        costMinor: Value(p.cost?.amountMinor),
        costCurrency: Value(p.cost?.currency),
        trackStock: Value(p.trackStock),
        isActive: Value(p.isActive),
      );

  @override
  Future<void> update(Product product) async {
    await (_db.update(_db.products)..where((t) => t.id.equals(product.id))).write(
      ProductsCompanion(
        name: Value(product.name),
        sellPriceMinor: Value(product.sellPrice.amountMinor),
        sellCurrency: Value(product.sellPrice.currency),
        isActive: Value(product.isActive),
        updatedAt: Value(DateTime.now().toUtc()),
        version: Value(product.version + 1),
      ),
    );
  }

  @override
  Future<Product?> findById(String id) async {
    final r = await (_db.select(_db.products)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return r == null ? null : _toProduct(r);
  }

  @override
  Future<Product?> findByBarcode(String code) async {
    final bc = await (_db.select(_db.barcodes)
          ..where((t) => t.code.equals(code) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return bc == null ? null : findById(bc.productId);
  }

  @override
  Future<List<Product>> list({String? search}) async {
    final q = _db.select(_db.products)..where((t) => t.deletedAt.isNull());
    if (search != null && search.isNotEmpty) {
      q.where((t) => t.name.like('%$search%') | t.sku.like('%$search%'));
    }
    q.orderBy([(t) => OrderingTerm(expression: t.name)]);
    return (await q.get()).map(_toProduct).toList();
  }

  @override
  Future<List<Barcode>> barcodesFor(String productId) async {
    final rows = await (_db.select(_db.barcodes)
          ..where((t) => t.productId.equals(productId) & t.deletedAt.isNull()))
        .get();
    return rows
        .map((r) => Barcode(id: r.id, productId: r.productId, code: r.code, symbology: r.symbology))
        .toList();
  }

  @override
  Future<void> addBarcode(Barcode barcode) async {
    await _db.into(_db.barcodes).insert(BarcodesCompanion.insert(
          id: barcode.id, productId: barcode.productId, code: barcode.code,
          symbology: Value(barcode.symbology),
        ));
  }

  @override
  Future<bool> skuTaken(String sku) async =>
      (await (_db.select(_db.products)
                ..where((t) => t.sku.equals(sku) & t.deletedAt.isNull()))
              .getSingleOrNull()) !=
      null;

  @override
  Future<bool> barcodeTaken(String code) async =>
      (await (_db.select(_db.barcodes)
                ..where((t) => t.code.equals(code) & t.deletedAt.isNull()))
              .getSingleOrNull()) !=
      null;
}

/// Drift-backed [StockMovementRepository] with on-hand derivation.
final class DriftStockRepository implements StockMovementRepository {
  DriftStockRepository(this._db);
  final AppDatabase _db;

  @override
  Future<void> append(StockMovement movement) async {
    await _db.into(_db.stockMovements).insert(StockMovementsCompanion.insert(
          id: movement.id, productId: movement.productId, branchId: movement.branchId,
          qtyDelta: movement.qtyDelta, reason: movement.reason.name,
          occurredAt: Value(movement.occurredAt),
        ));
  }

  @override
  Future<List<StockMovement>> forProduct(String productId, String branchId) async {
    final rows = await (_db.select(_db.stockMovements)
          ..where((t) =>
              t.productId.equals(productId) & t.branchId.equals(branchId) & t.deletedAt.isNull()))
        .get();
    return rows
        .map((r) => StockMovement(
              id: r.id, productId: r.productId, branchId: r.branchId, qtyDelta: r.qtyDelta,
              reason: StockReason.values.byName(r.reason), occurredAt: r.occurredAt,
            ))
        .toList();
  }

  Future<int> onHand(String productId, String branchId) async {
    final movements = await forProduct(productId, branchId);
    return movements.fold<int>(0, (sum, m) => sum + m.qtyDelta);
  }
}

/// Local, offline-first catalog orchestration: every write is committed to
/// SQLite AND enqueued as a row-level op in the outbox, in one transaction
/// (sync-shaped). See docs/sync-protocol.md.
final class LocalCatalog {
  LocalCatalog(this._db)
      : products = ProductDao(_db),
        stock = DriftStockRepository(_db),
        _rec = SyncRecorder(_db);

  final AppDatabase _db;
  final ProductDao products;
  final DriftStockRepository stock;
  final SyncRecorder _rec;

  /// The units, with the built-in ones seeded on first use. They carry the
  /// same fixed ids as on the server and every other device, so they are not
  /// queued for sync and never duplicate.
  Future<List<UnitRow>> listUnits() async {
    var rows = await (_db.select(_db.units)..where((t) => t.deletedAt.isNull())).get();
    if (rows.isEmpty) {
      await _db.transaction(() async {
        for (final u in builtInUnits) {
          await _db.into(_db.units).insert(
                UnitsCompanion.insert(id: u.id, name: u.name, decimalPlaces: Value(u.decimalPlaces)),
                mode: InsertMode.insertOrIgnore,
              );
        }
      });
      rows = await (_db.select(_db.units)..where((t) => t.deletedAt.isNull())).get();
    }
    return rows;
  }

  Map<String, Object?> _productData(Product p) => {
        'sku': p.sku,
        'name': p.name,
        'unit_id': p.unitId,
        'category_id': p.categoryId,
        'sell_price_minor': p.sellPrice.amountMinor,
        'sell_currency': p.sellPrice.currency,
        'cost_minor': p.cost?.amountMinor,
        'cost_currency': p.cost?.currency,
        'track_stock': p.trackStock,
        'is_active': p.isActive,
      };

  Future<void> createProduct(
    Product product, {
    List<Barcode> barcodes = const [],
    required String actorId,
    required String deviceId,
  }) async {
    assertPriceValid(sellPriceMinor: product.sellPrice.amountMinor);
    await _db.transaction(() async {
      await products.create(product, barcodes: barcodes);
      await _rec.record(
        table: 'products', rowId: product.id, op: 'insert',
        data: _productData(product), actorId: actorId, deviceId: deviceId,
      );
      for (final b in barcodes) {
        await _rec.record(
          table: 'barcodes', rowId: b.id, op: 'insert',
          data: {'product_id': b.productId, 'code': b.code, 'symbology': b.symbology},
          actorId: actorId, deviceId: deviceId,
        );
      }
    });
  }

  Future<void> updateProduct(
    Product product, {
    required String actorId,
    required String deviceId,
  }) async {
    assertPriceValid(sellPriceMinor: product.sellPrice.amountMinor);
    await _db.transaction(() async {
      await products.update(product);
      await _rec.record(
        table: 'products', rowId: product.id, op: 'update', baseVersion: product.version,
        data: {
          'name': product.name,
          'sell_price_minor': product.sellPrice.amountMinor,
          'sell_currency': product.sellPrice.currency,
          'is_active': product.isActive,
        },
        actorId: actorId, deviceId: deviceId,
      );
    });
  }

  Future<void> adjust({
    required String productId,
    required String branchId,
    required int qtyDelta,
    required String actorId,
    required String deviceId,
  }) async {
    final movement = adjustStock(
      id: newId(), productId: productId, branchId: branchId,
      qtyDelta: qtyDelta, at: DateTime.now().toUtc(),
    );
    await _db.transaction(() async {
      await stock.append(movement);
      await _rec.record(
        table: 'stock_movements', rowId: movement.id, op: 'insert',
        data: {'product_id': productId, 'branch_id': branchId, 'qty_delta': qtyDelta, 'reason': 'adjustment'},
        actorId: actorId, deviceId: deviceId,
      );
    });
  }

  Future<int> onHand(String productId, String branchId) => stock.onHand(productId, branchId);
}
