import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart';

part 'database.g.dart';

/// The standard record columns carried by every table (platform invariant):
/// id, created_at, updated_at, deleted_at, created_by, updated_by, version.
mixin RecordColumns on Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get updatedBy => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
}

/// The offline operation queue. One row per intent operation; see
/// docs/sync-protocol.md. `id` is the op_id / idempotency key.
@DataClassName('OutboxRow')
class OutboxEntries extends Table with RecordColumns {
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get opType => text()();
  TextColumn get payload => text()(); // JSON
  IntColumn get localSeq => integer()();
  TextColumn get deviceId => text()();
  TextColumn get actorId => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get baseVersion => integer().nullable()();
  /// The server's code for an op it conflicted or rejected (shown for review).
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached authenticated profile, for offline unlock. The server is
/// authoritative; this is a denormalised read cache.
@DataClassName('CachedProfileRow')
class CachedProfiles extends Table {
  TextColumn get userId => text()();
  TextColumn get username => text()();
  TextColumn get displayName => text()();
  TextColumn get defaultBranchId => text().nullable()();
  TextColumn get branches => text()(); // JSON array of {branch_id,branch_name,role_name}
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}

// ── Catalog + inventory (Phase 2) ────────────────────────────────────────────

@DataClassName('UnitRow')
class Units extends Table with RecordColumns {
  TextColumn get name => text()();
  IntColumn get decimalPlaces => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryRow')
class Categories extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductRow')
class Products extends Table with RecordColumns {
  TextColumn get sku => text()();
  TextColumn get name => text()();
  TextColumn get unitId => text()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get sellPriceMinor => integer().withDefault(const Constant(0))();
  TextColumn get sellCurrency => text().withDefault(const Constant('AFN'))();
  IntColumn get costMinor => integer().nullable()();
  TextColumn get costCurrency => text().nullable()();
  BoolColumn get trackStock => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BarcodeRow')
class Barcodes extends Table with RecordColumns {
  TextColumn get productId => text()();
  TextColumn get code => text()();
  TextColumn get symbology => text().withDefault(const Constant('ean13'))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StockMovementRow')
class StockMovements extends Table with RecordColumns {
  TextColumn get productId => text()();
  TextColumn get branchId => text()();
  IntColumn get qtyDelta => integer()();
  TextColumn get reason => text()();
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

// ── Sales / POS (Phase 3) ────────────────────────────────────────────────────

@DataClassName('SaleRow')
class Sales extends Table with RecordColumns {
  TextColumn get number => text()();
  TextColumn get branchId => text()();
  TextColumn get shiftId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('settled'))();
  TextColumn get currency => text().withDefault(const Constant('AFN'))();
  IntColumn get discountMinor => integer().withDefault(const Constant(0))();
  IntColumn get subtotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get taxMinor => integer().withDefault(const Constant(0))();
  IntColumn get totalMinor => integer().withDefault(const Constant(0))();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get changeMinor => integer().withDefault(const Constant(0))();
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleLineRow')
class SaleLines extends Table with RecordColumns {
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  TextColumn get name => text()();
  IntColumn get qtyMinor => integer()();
  IntColumn get decimalPlaces => integer().withDefault(const Constant(0))();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get unitCostMinor => integer().withDefault(const Constant(0))();
  IntColumn get lineTotalMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('AFN'))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PaymentRow')
class Payments extends Table with RecordColumns {
  TextColumn get saleId => text()();
  TextColumn get method => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('AFN'))();
  IntColumn get tenderedMinor => integer().nullable()();
  IntColumn get changeMinor => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ShiftRow')
class Shifts extends Table with RecordColumns {
  TextColumn get branchId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get openingFloatMinor => integer().withDefault(const Constant(0))();
  DateTimeColumn get closedAt => dateTime().nullable()();
  IntColumn get countedCashMinor => integer().nullable()();
  IntColumn get expectedCashMinor => integer().nullable()();
  IntColumn get varianceMinor => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  @override
  Set<Column> get primaryKey => {id};
}

// ── Customers, debt, suppliers (Phase 4) ─────────────────────────────────────

@DataClassName('CustomerRow')
class Customers extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  IntColumn get creditLimitMinor => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('AFN'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CustomerLedgerRow')
class CustomerLedger extends Table with RecordColumns {
  TextColumn get customerId => text()();
  /// A debt payment: how it was paid, and the shift whose drawer it went into.
  TextColumn get method => text().nullable()();
  TextColumn get shiftId => text().nullable()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('AFN'))();
  TextColumn get refType => text().nullable()();
  TextColumn get refId => text().nullable()();
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SupplierRow')
class Suppliers extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('AFN'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SupplierLedgerRow')
class SupplierLedger extends Table with RecordColumns {
  TextColumn get supplierId => text()();
  /// A payment: how it was paid, and the shift whose drawer it came out of.
  TextColumn get method => text().nullable()();
  TextColumn get shiftId => text().nullable()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('AFN'))();
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

// ── Sync (Phase 6) ───────────────────────────────────────────────────────────

@DataClassName('SyncStateRow')
class SyncStates extends Table {
  TextColumn get deviceId => text()();
  IntColumn get lastPulledSeq => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {deviceId};
}

// ── Local app settings (Phase 8): device-local key/value (printer config, …) ──

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    OutboxEntries, CachedProfiles, Units, Categories, Products, Barcodes, StockMovements,
    Sales, SaleLines, Payments, Shifts,
    Customers, CustomerLedger, Suppliers, SupplierLedger,
    SyncStates, AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(units);
            await m.createTable(categories);
            await m.createTable(products);
            await m.createTable(barcodes);
            await m.createTable(stockMovements);
          }
          if (from < 3) {
            await m.createTable(sales);
            await m.createTable(saleLines);
            await m.createTable(payments);
            await m.createTable(shifts);
          }
          if (from < 4) {
            await m.createTable(customers);
            await m.createTable(customerLedger);
            await m.createTable(suppliers);
            await m.createTable(supplierLedger);
          }
          if (from < 5) {
            await m.createTable(syncStates);
          }
          if (from < 6) {
            await m.createTable(appSettings);
          }
          if (from < 8 && !await _hasColumn('outbox_entries', 'last_error')) {
            // First: the v7 step reads the outbox through today's table definition.
            await m.addColumn(outboxEntries, outboxEntries.lastError);
          }
          if (from < 7) {
            await _refLegacySaleMovements();
          }
          if (from < 9) {
            await _mergeUnitCopies();
          }
          if (from < 10) {
            for (final column in [customerLedger.method, customerLedger.shiftId]) {
              if (!await _hasColumn('customer_ledger', column.$name)) {
                await m.addColumn(customerLedger, column);
              }
            }
          }
          if (from < 11) {
            for (final column in [supplierLedger.method, supplierLedger.shiftId]) {
              if (!await _hasColumn('supplier_ledger', column.$name)) {
                await m.addColumn(supplierLedger, column);
              }
            }
          }
        },
      );

  /// Before the built-in units had fixed ids (dukan_core `builtInUnits`), every
  /// device seeded the five with ids of its own and queued them, so a device
  /// that synced held several "kg". Products move to the fixed unit and the
  /// copies are set aside; queued ops follow (a copy's own insert is set aside,
  /// a product op names the fixed unit). The server merges its copies the same
  /// way (migration 0012).
  Future<void> _mergeUnitCopies() async {
    final now = DateTime.now().toUtc();
    final fixedOf = <String, String>{}; // copy id -> fixed id
    for (final u in builtInUnits) {
      await into(units).insert(
        UnitsCompanion.insert(id: u.id, name: u.name, decimalPlaces: Value(u.decimalPlaces)),
        mode: InsertMode.insertOrIgnore,
      );
      final copies = await (select(units)
            ..where((t) =>
                t.name.equals(u.name) &
                t.decimalPlaces.equals(u.decimalPlaces) &
                t.id.equals(u.id).not() &
                t.deletedAt.isNull()))
          .get();
      for (final c in copies) {
        fixedOf[c.id] = u.id;
      }
    }
    if (fixedOf.isEmpty) return;
    for (final MapEntry(key: copy, value: fixed) in fixedOf.entries) {
      await (update(products)..where((t) => t.unitId.equals(copy)))
          .write(ProductsCompanion(unitId: Value(fixed)));
    }
    await (update(units)..where((t) => t.id.isIn(fixedOf.keys)))
        .write(UnitsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    final queued = await (select(outboxEntries)
          ..where((t) =>
              t.status.equals(OutboxStatus.pending.name) &
              t.aggregateType.isIn(const ['units', 'products'])))
        .get();
    for (final op in queued) {
      if (op.aggregateType == 'units') {
        if (fixedOf.containsKey(op.aggregateId)) {
          await (update(outboxEntries)..where((t) => t.id.equals(op.id)))
              .write(const OutboxEntriesCompanion(status: Value('dismissed')));
        }
        continue;
      }
      final data = (jsonDecode(op.payload) as Map).cast<String, Object?>();
      final fixed = fixedOf[data['unit_id']];
      if (fixed != null) {
        await (update(outboxEntries)..where((t) => t.id.equals(op.id)))
            .write(OutboxEntriesCompanion(payload: Value(jsonEncode({...data, 'unit_id': fixed}))));
      }
    }
  }

  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info("$table")').get();
    return rows.any((r) => r.read<String>('name') == column);
  }

  /// Sale stock movements the app recorded before v7 carry no ref to their
  /// sale, and the hardened server rejects them (docs/sync-protocol.md,
  /// "Rollout"). LocalSales.settle records a sale's ops contiguously in one
  /// transaction, so a movement's sale is the nearest earlier `sales` op in the
  /// same branch. Ops already sent are left as they are.
  Future<void> _refLegacySaleMovements() async {
    final ops = await (select(outboxEntries)..orderBy([(t) => OrderingTerm(expression: t.localSeq)])).get();
    String? saleId;
    String? saleBranch;
    for (final op in ops) {
      if (op.aggregateType == 'sales') {
        saleId = op.aggregateId;
        saleBranch = (jsonDecode(op.payload) as Map<String, Object?>)['branch_id'] as String?;
        continue;
      }
      if (op.aggregateType != 'stock_movements' || op.status != OutboxStatus.pending.name) continue;
      final data = jsonDecode(op.payload) as Map<String, Object?>;
      if (data['reason'] != 'sale' || data['ref_id'] != null) continue;
      if (saleId == null || data['branch_id'] != saleBranch) continue;
      await (update(outboxEntries)..where((t) => t.id.equals(op.id))).write(OutboxEntriesCompanion(
        payload: Value(jsonEncode({...data, 'ref_type': 'sale', 'ref_id': saleId})),
      ));
    }
  }
}

/// Drift-backed implementation of the dukan_core [SyncOutbox] port.
final class DriftSyncOutbox implements SyncOutbox {
  DriftSyncOutbox(this._db);
  final AppDatabase _db;

  @override
  Future<void> enqueue(OutboxOp op) async {
    await _db.into(_db.outboxEntries).insert(
          OutboxEntriesCompanion.insert(
            id: op.opId,
            aggregateType: op.aggregateType,
            aggregateId: op.aggregateId,
            opType: op.opType,
            payload: jsonEncode(op.payload),
            localSeq: op.localSeq,
            deviceId: op.deviceId,
            actorId: op.actorId,
            status: Value(op.status.name),
            baseVersion: Value(op.baseVersion),
            createdAt: Value(op.createdAt),
          ),
        );
  }

  @override
  Future<List<OutboxOp>> pending() async {
    final rows = await (_db.select(_db.outboxEntries)
          ..where((t) => t.status.equals(OutboxStatus.pending.name))
          ..orderBy([(t) => OrderingTerm(expression: t.localSeq)]))
        .get();
    return rows.map(_toOp).toList(growable: false);
  }

  @override
  Future<void> markAcked(String opId) async {
    await (_db.update(_db.outboxEntries)..where((t) => t.id.equals(opId)))
        .write(const OutboxEntriesCompanion(status: Value('acked')));
  }

  OutboxOp _toOp(OutboxRow r) => OutboxOp(
        opId: r.id,
        aggregateType: r.aggregateType,
        aggregateId: r.aggregateId,
        opType: r.opType,
        payload: jsonDecode(r.payload) as Map<String, Object?>,
        localSeq: r.localSeq,
        deviceId: r.deviceId,
        actorId: r.actorId,
        createdAt: r.createdAt,
        baseVersion: r.baseVersion,
        status: OutboxStatus.values.byName(r.status),
      );
}

/// Local cache of the authenticated profile (for offline unlock).
final class ProfileStore {
  ProfileStore(this._db);
  final AppDatabase _db;

  Future<void> save({
    required String userId,
    required String username,
    required String displayName,
    String? defaultBranchId,
    required List<Map<String, Object?>> branches,
  }) async {
    await _db.into(_db.cachedProfiles).insertOnConflictUpdate(
          CachedProfilesCompanion.insert(
            userId: userId,
            username: username,
            displayName: displayName,
            defaultBranchId: Value(defaultBranchId),
            branches: jsonEncode(branches),
          ),
        );
  }

  /// The one signed-in user's profile: replaces whatever was cached, in one
  /// transaction, so the device never answers with another user's role.
  Future<void> replace({
    required String userId,
    required String username,
    required String displayName,
    String? defaultBranchId,
    required List<Map<String, Object?>> branches,
  }) =>
      _db.transaction(() async {
        await clear();
        await save(
          userId: userId, username: username, displayName: displayName,
          defaultBranchId: defaultBranchId, branches: branches,
        );
      });

  Future<CachedProfileRow?> current() async {
    final rows = await _db.select(_db.cachedProfiles).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> clear() async => _db.delete(_db.cachedProfiles).go();
}
