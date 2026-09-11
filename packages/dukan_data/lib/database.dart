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

@DriftDatabase(
  tables: [OutboxEntries, CachedProfiles, Units, Categories, Products, Barcodes, StockMovements],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

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
        },
      );
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

  Future<CachedProfileRow?> current() async {
    final rows = await _db.select(_db.cachedProfiles).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> clear() async => _db.delete(_db.cachedProfiles).go();
}
