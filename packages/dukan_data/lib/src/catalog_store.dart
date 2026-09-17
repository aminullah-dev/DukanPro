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
        sku: Value(product.sku),
        name: Value(product.name),
        sellPriceMinor: Value(product.sellPrice.amountMinor),
        sellCurrency: Value(product.sellPrice.currency),
        isActive: Value(product.isActive),
        trackStock: Value(product.trackStock),
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

  /// The sellable product a scan names: the oldest live barcode with that code on
  /// an active product, else with its UPC-A/EAN-13 twin ([barcodeLookupCodes]),
  /// so a product scans the same from Android's camera, an iPhone's, or a
  /// keyboard-wedge scanner. Rows another till synced before codes were unique
  /// may repeat a code; they never make a scan throw.
  @override
  Future<Product?> findByBarcode(String code) async {
    for (final candidate in barcodeLookupCodes(code)) {
      final product = await _findByExactBarcode(candidate);
      if (product != null) return product;
    }
    return null;
  }

  Future<Product?> _findByExactBarcode(String code) async {
    final query = _db.select(_db.barcodes).join([
      innerJoin(_db.products, _db.products.id.equalsExp(_db.barcodes.productId)),
    ])
      ..where(_db.barcodes.code.equals(code) &
          _db.barcodes.deletedAt.isNull() &
          _db.products.deletedAt.isNull() &
          _db.products.isActive.equals(true))
      ..orderBy([
        OrderingTerm(expression: _db.barcodes.createdAt),
        OrderingTerm(expression: _db.barcodes.id),
      ])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _toProduct(row.readTable(_db.products));
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
  Future<bool> skuTaken(String sku) async => (await (_db.select(_db.products)
            ..where((t) => t.sku.equals(sku) & t.deletedAt.isNull())
            ..limit(1))
          .get())
      .isNotEmpty;

  @override
  Future<bool> barcodeTaken(String code) async => (await (_db.select(_db.barcodes)
            ..where((t) => t.code.equals(code) & t.deletedAt.isNull())
            ..limit(1))
          .get())
      .isNotEmpty;
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

  /// The units. The built-in ones carry the same fixed ids as on the server and
  /// every other device, so they are never queued for sync. Any that are
  /// missing are added on every read, not only on a first one: a product made
  /// elsewhere in a built-in unit must resolve here too.
  Future<List<UnitRow>> listUnits() async {
    final ids = [for (final u in builtInUnits) u.id];
    final have = {
      for (final r in await (_db.select(_db.units)..where((t) => t.id.isIn(ids))).get()) r.id,
    };
    final missing = [for (final u in builtInUnits) if (!have.contains(u.id)) u];
    if (missing.isNotEmpty) {
      await _db.batch((b) => b.insertAll(
            _db.units,
            [
              for (final u in missing)
                UnitsCompanion.insert(id: u.id, name: u.name, decimalPlaces: Value(u.decimalPlaces)),
            ],
            mode: InsertMode.insertOrIgnore,
          ));
    }
    return (_db.select(_db.units)..where((t) => t.deletedAt.isNull())).get();
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
      // Unique among live products and barcodes on this device, as on the server.
      if (await products.skuTaken(product.sku)) {
        throw ConflictError('PRODUCT_DUPLICATE_SKU', {'sku': product.sku});
      }
      for (final b in barcodes) {
        if (await products.barcodeTaken(b.code)) throw ConflictError('BARCODE_DUPLICATE', {'barcode': b.code});
      }
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

  /// Saves an edit, queued with only the fields that changed (the edit's intent)
  /// against the version it was made on. When nothing changed, nothing is queued.
  Future<void> updateProduct(
    Product product, {
    required String actorId,
    required String deviceId,
  }) async {
    assertPriceValid(sellPriceMinor: product.sellPrice.amountMinor);
    await _db.transaction(() async {
      final before = await (_db.select(_db.products)..where((t) => t.id.equals(product.id))).getSingle();
      if (before.sku != product.sku && await products.skuTaken(product.sku)) {
        throw ConflictError('PRODUCT_DUPLICATE_SKU', {'sku': product.sku}); // a mistyped SKU is corrected
      }
      final changed = <String, Object?>{
        if (before.sku != product.sku) 'sku': product.sku,
        if (before.name != product.name) 'name': product.name,
        if (before.sellPriceMinor != product.sellPrice.amountMinor)
          'sell_price_minor': product.sellPrice.amountMinor,
        if (before.sellCurrency != product.sellPrice.currency) 'sell_currency': product.sellPrice.currency,
        if (before.isActive != product.isActive) 'is_active': product.isActive,
        if (before.trackStock != product.trackStock) 'track_stock': product.trackStock,
      };
      if (changed.isEmpty) return;
      await products.update(product);
      await _rec.record(
        table: 'products', rowId: product.id, op: 'update', baseVersion: product.version,
        data: changed, actorId: actorId, deviceId: deviceId,
      );
    });
  }

  /// Adds [code] to a product: unique among live barcodes (`BARCODE_DUPLICATE`).
  Future<Barcode> addBarcode(
    String productId,
    String code, {
    required String actorId,
    required String deviceId,
  }) async {
    final barcode = Barcode(id: newId(), productId: productId, code: code);
    await _db.transaction(() async {
      if (await products.barcodeTaken(code)) throw ConflictError('BARCODE_DUPLICATE', {'barcode': code});
      await products.addBarcode(barcode);
      await _rec.record(
        table: 'barcodes', rowId: barcode.id, op: 'insert',
        data: {'product_id': productId, 'code': code, 'symbology': barcode.symbology},
        actorId: actorId, deviceId: deviceId,
      );
    });
    return barcode;
  }

  /// Takes a barcode off its product, so the code can go on another one: a
  /// synced edit of the barcode row, which the server soft-deletes everywhere.
  Future<void> removeBarcode(String barcodeId, {required String actorId, required String deviceId}) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.barcodes)
            ..where((t) => t.id.equals(barcodeId) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (row == null) return;
      final now = DateTime.now().toUtc();
      await (_db.update(_db.barcodes)..where((t) => t.id.equals(barcodeId))).write(
        BarcodesCompanion(deletedAt: Value(now), updatedAt: Value(now), version: Value(row.version + 1)),
      );
      await _rec.record(
        table: 'barcodes', rowId: barcodeId, op: 'update', baseVersion: row.version,
        data: {'deleted': true}, actorId: actorId, deviceId: deviceId,
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
    final product = await products.findById(productId);
    if (product == null) throw NotFoundError('PRODUCT_NOT_FOUND', {'product_id': productId});
    // An untracked product (a service) has no stock to adjust, as on the server.
    if (!product.trackStock) throw ValidationError('PRODUCT_NOT_STOCK_TRACKED', {'product_id': productId});
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
