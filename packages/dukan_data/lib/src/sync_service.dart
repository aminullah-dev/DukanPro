import 'dart:convert';
import 'dart:math' show min;

import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart' show systemActorId;
import 'package:dukan_sync/dukan_sync.dart';

import '../database.dart';
import 'settings_store.dart';
import 'sync_recorder.dart';

int _i(Object? v) => (v as num?)?.toInt() ?? 0;
int? _iN(Object? v) => (v as num?)?.toInt();
String _s(Object? v) => v as String? ?? '';
String? _sN(Object? v) => v as String?;
bool _b(Object? v) => v as bool? ?? true;
DateTime _t(Object? v) => DateTime.parse(v! as String).toUtc();
DateTime? _tN(Object? v) => v == null ? null : _t(v);

/// A pulled value, or absent when the server omitted the key (a field hidden
/// from the pulling user, e.g. cost): the write then keeps the local value.
Value<T> _opt<T>(Map<String, Object?> d, String key, T Function(Object?) read) =>
    d.containsKey(key) ? Value(read(d[key])) : Value<T>.absent();

/// Rejections the server does not record against the op, because they depend on
/// state that can change: a parent row still queued by another user, a role
/// granted later, an op pushed under another user's token, an unexpected server
/// error. Nothing was applied, so the op stays pending and is re-sent on the
/// next sync. Mirrors `is_cacheable` in server/dukan/application/sync_policy.py.
bool _retryable(String? code) =>
    code != null && (code.endsWith('_NOT_FOUND') || _retryableCodes.contains(code));

const _retryableCodes = {
  'ACCESS_DENIED', 'SYNC_ACTOR_MISMATCH', 'BRANCH_REQUIRED', 'BRANCH_INACTIVE', 'ROW_INVALID',
};

/// The synced tables this app version keeps.
const _tables = {
  'products', 'barcodes', 'units', 'categories', 'customers', 'suppliers', 'stock_movements',
  'sales', 'sale_lines', 'payments', 'customer_ledger', 'supplier_ledger', 'shifts',
};

/// Outbox ops by state, for the sync badge and card.
final class SyncCounts {
  const SyncCounts({this.pending = 0, this.conflicts = 0, this.rejected = 0});
  final int pending;
  final int conflicts;
  final int rejected;
}

/// An op the server conflicted or rejected, for the review list.
final class SyncIssue {
  const SyncIssue({
    required this.opId,
    required this.table,
    required this.rowId,
    required this.op,
    required this.status,
    required this.code,
    required this.createdAt,
    required this.payload,
  });
  final String opId;
  final String table;
  final String rowId;
  final String op;
  final String status; // conflict | rejected
  final String? code;
  final DateTime createdAt;
  final Map<String, Object?> payload;

  /// A conflicted edit can be made again on top of the server's row.
  bool get canRetry => status == 'conflict' && op == 'update';
}

/// Drains the outbox to the server and applies server changes back — the
/// offline-first sync loop. See docs/sync-protocol.md.
final class SyncEngine {
  SyncEngine(this._db, this._client, {this.deviceId = 'app'});
  final AppDatabase _db;
  final SyncClient _client;
  final String deviceId;

  /// Pull pages per sync at most; the next sync resumes from the saved cursor.
  static const maxPullPages = 50;

  /// Ops per push request, below the server's cap of 500 (docs/sync-protocol.md).
  static const maxPushBatch = 200;

  /// Pulled changes this device could not apply, kept for support (newest last).
  static const quarantineKey = 'sync.quarantine';
  static const _quarantineMax = 50;

  /// Pushes then pulls as [actorId], the signed-in user. Null pushes every
  /// pending op and pulls through one device-wide cursor.
  Future<void> syncNow({String? actorId}) async {
    await pushPending(actorId: actorId);
    await pullSince(actorId: actorId);
  }

  Future<int> pendingCount() => _countByStatus('pending');

  Future<int> conflictCount() => _countByStatus('conflict');

  Future<int> rejectedCount() => _countByStatus('rejected');

  Future<int> _countByStatus(String status) async {
    final c = _db.outboxEntries.id.count();
    final row = await (_db.selectOnly(_db.outboxEntries)
          ..addColumns([c])
          ..where(_db.outboxEntries.status.equals(status)))
        .getSingle();
    return row.read(c) ?? 0;
  }

  /// Live counts: they change with every local write and every sync.
  Stream<SyncCounts> watchCounts() {
    final status = _db.outboxEntries.status;
    final count = _db.outboxEntries.id.count();
    final query = _db.selectOnly(_db.outboxEntries)
      ..addColumns([status, count])
      ..groupBy([status]);
    return query.watch().map((rows) {
      int of(String s) => rows.where((r) => r.read(status) == s).fold(0, (n, r) => n + (r.read(count) ?? 0));
      return SyncCounts(pending: of('pending'), conflicts: of('conflict'), rejected: of('rejected'));
    });
  }

  /// Pushes, in local_seq order, the pending ops [actorId] recorded plus the
  /// system seeds. The server applies an op only under the token of the user
  /// who recorded it, so another user's ops wait for that user's own sync.
  Future<void> pushPending({String? actorId}) async {
    final outbox = DriftSyncOutbox(_db);
    final pending = [
      for (final o in await outbox.pending())
        if (actorId == null || o.actorId == actorId || o.actorId == systemActorId) o,
    ];
    for (var i = 0; i < pending.length; i += maxPushBatch) {
      final batch = pending.sublist(i, min(i + maxPushBatch, pending.length));
      final byId = {for (final o in batch) o.opId: o};
      final results = await _client.push(batch);
      for (final r in results) {
        switch (r.outcome) {
          case OpOutcome.applied:
            await outbox.markAcked(r.opId);
          case OpOutcome.conflict:
            await _setStatus(r.opId, 'conflict', code: r.code);
            final op = byId[r.opId];
            final current = r.current;
            if (op != null && current != null) {
              // The server's state wins: the losing local copy is replaced, and the
              // edit waits in the review list to be made again or set aside.
              await _db.transaction(
                  () => _apply(op.aggregateType, op.aggregateId, 'update', current, force: true));
            }
          case OpOutcome.rejected:
            if (!_retryable(r.code)) await _setStatus(r.opId, 'rejected', code: r.code);
        }
      }
    }
  }

  /// Pulls every page since [actorId]'s cursor. The server returns only the rows
  /// that user may read and moves the watermark past the rest, so each user
  /// keeps their own cursor: a row hidden from one user still reaches this
  /// device when another user syncs on it. A user's first cursor starts from
  /// the device-wide one (pulls made before per-user cursors were unscoped).
  Future<void> pullSince({String? actorId}) async {
    final cursor = actorId == null ? deviceId : '$deviceId/$actorId';
    var since = await _lastPulled(cursor) ?? await _lastPulled(deviceId) ?? 0;
    for (var page = 0; page < maxPullPages; page++) {
      final result = await _client.pull(sinceWatermark: since);
      final maxSeq = result.maxSeq;
      if (maxSeq != null && since > maxSeq) {
        // The server was restored from a backup: its feed now ends below this
        // device's cursor. Read it again from the start (applying is idempotent).
        since = 0;
        await _setLastPulled(cursor, 0);
        continue;
      }
      await _db.transaction(() async {
        final unreadable = <Map<String, Object?>>[];
        for (final change in result.changed) {
          try {
            await _apply(
              _s(change['table']),
              _s(change['row_id']),
              _s(change['op']),
              (change['data'] as Map).cast<String, Object?>(),
            );
          } on Object catch (e) {
            // One change this device cannot read must not stop every later one:
            // set it aside for support and go on.
            final error = '$e';
            unreadable.add({
              'seq': change['seq'], 'table': change['table'], 'row_id': change['row_id'],
              'error': error.substring(0, min(200, error.length)),
            });
          }
        }
        if (unreadable.isNotEmpty) await _quarantine(unreadable);
        if (result.watermark > since) await _setLastPulled(cursor, result.watermark);
      });
      if (result.watermark <= since) break; // caught up
      since = result.watermark;
    }
  }

  /// Conflicted and rejected ops, newest first, for the review list.
  Future<List<SyncIssue>> issues() async {
    final rows = await (_db.select(_db.outboxEntries)
          ..where((t) => t.status.isIn(const ['conflict', 'rejected']))
          ..orderBy([(t) => OrderingTerm.desc(t.localSeq)]))
        .get();
    return [
      for (final r in rows)
        SyncIssue(
          opId: r.id, table: r.aggregateType, rowId: r.aggregateId, op: r.opType,
          status: r.status, code: r.lastError, createdAt: r.createdAt,
          payload: (jsonDecode(r.payload) as Map).cast<String, Object?>(),
        ),
    ];
  }

  /// Sets an issue aside: it stays in the outbox for support, off the counts.
  Future<void> dismiss(String opId) => _setStatus(opId, 'dismissed');

  /// Makes a conflicted edit again on top of the server's row: the change is
  /// written locally again and queued against the server's current version.
  /// False when the op cannot be made again (a rejection, an insert).
  Future<bool> retry(String opId) async {
    final row =
        await (_db.select(_db.outboxEntries)..where((t) => t.id.equals(opId))).getSingleOrNull();
    if (row == null || row.status != 'conflict' || row.opType != 'update') return false;
    final base = await _localVersion(row.aggregateType, row.aggregateId);
    if (base == null) return false;
    final payload = (jsonDecode(row.payload) as Map).cast<String, Object?>();
    await _db.transaction(() async {
      await _apply(row.aggregateType, row.aggregateId, 'update', {...payload, 'version': base + 1},
          force: true);
      await SyncRecorder(_db).record(
        table: row.aggregateType, rowId: row.aggregateId, op: 'update', data: payload,
        baseVersion: base, actorId: row.actorId, deviceId: row.deviceId,
      );
      await _setStatus(opId, 'dismissed');
    });
    return true;
  }

  Future<void> _quarantine(List<Map<String, Object?>> unreadable) async {
    final settings = SettingsStore(_db);
    final raw = await settings.get(quarantineKey);
    final kept = [...(raw == null ? const <Object?>[] : jsonDecode(raw) as List), ...unreadable];
    final start = kept.length > _quarantineMax ? kept.length - _quarantineMax : 0;
    await settings.set(quarantineKey, jsonEncode(kept.sublist(start)));
  }

  Future<int?> _lastPulled(String cursor) async {
    final row = await (_db.select(_db.syncStates)..where((t) => t.deviceId.equals(cursor)))
        .getSingleOrNull();
    return row?.lastPulledSeq;
  }

  Future<void> _setLastPulled(String cursor, int seq) async {
    await _db.into(_db.syncStates).insertOnConflictUpdate(
          SyncStatesCompanion.insert(deviceId: cursor, lastPulledSeq: Value(seq)),
        );
  }

  Future<void> _setStatus(String opId, String status, {String? code}) async {
    await (_db.update(_db.outboxEntries)..where((t) => t.id.equals(opId))).write(OutboxEntriesCompanion(
      status: Value(status),
      lastError: code == null ? const Value.absent() : Value(code),
    ));
  }

  /// The local row's version, or null when this device does not have the row.
  Future<int?> _localVersion(String table, String id) async {
    if (!_tables.contains(table)) return null;
    final row = await _db
        .customSelect('SELECT version FROM "$table" WHERE id = ?', variables: [Variable<String>(id)])
        .getSingleOrNull();
    return row?.read<int>('version');
  }

  Future<void> _write<T extends Table, D>(TableInfo<T, D> table, String id, bool exists, Insertable<D> row) async {
    if (exists) {
      await (_db.update(table)..where((t) => (t as RecordColumns).id.equals(id))).write(row);
    } else {
      await _db.into(table).insertOnConflictUpdate(row);
    }
  }

  /// Writes a pulled post-image (or a conflict's server row, or an edit made
  /// again), setting only the keys present so a field hidden from this user keeps
  /// its local value.
  Future<void> _apply(String table, String id, String op, Map<String, Object?> d, {bool force = false}) async {
    if (!_tables.contains(table)) return; // a table this app version does not keep
    final local = await _localVersion(table, id);
    final pulled = _iN(d['version']);
    // A master post-image older than the local row (edits not yet pushed) must not
    // rewind it: the server's newer image comes later in the feed. Another user of
    // the device pulling from an older cursor re-reads such images. Only a
    // conflict's server row overrides local edits ([force]): the server's state wins.
    if (!force && local != null && pulled != null && local > pulled) return;
    final exists = local != null;
    switch (table) {
      case 'products':
        await _write(_db.products, id, exists, ProductsCompanion(
          id: Value(id), sku: _opt(d, 'sku', _s), name: _opt(d, 'name', _s),
          unitId: _opt(d, 'unit_id', _s), categoryId: _opt(d, 'category_id', _sN),
          sellPriceMinor: _opt(d, 'sell_price_minor', _i), sellCurrency: _opt(d, 'sell_currency', _s),
          costMinor: _opt(d, 'cost_minor', _iN), costCurrency: _opt(d, 'cost_currency', _sN),
          trackStock: _opt(d, 'track_stock', _b), isActive: _opt(d, 'is_active', _b),
          version: _opt(d, 'version', _i),
        ));
      case 'barcodes':
        await _write(_db.barcodes, id, exists, BarcodesCompanion(
          id: Value(id), productId: _opt(d, 'product_id', _s), code: _opt(d, 'code', _s),
          symbology: _opt(d, 'symbology', _s), version: _opt(d, 'version', _i),
          deletedAt: _opt(d, 'deleted_at', _tN), // a barcode taken off its product
        ));
      case 'units':
        await _write(_db.units, id, exists, UnitsCompanion(
          id: Value(id), name: _opt(d, 'name', _s), decimalPlaces: _opt(d, 'decimal_places', _i),
          version: _opt(d, 'version', _i),
        ));
      case 'categories':
        await _write(_db.categories, id, exists, CategoriesCompanion(
          id: Value(id), name: _opt(d, 'name', _s), parentId: _opt(d, 'parent_id', _sN),
          version: _opt(d, 'version', _i),
        ));
      case 'customers':
        await _write(_db.customers, id, exists, CustomersCompanion(
          id: Value(id), name: _opt(d, 'name', _s), phone: _opt(d, 'phone', _sN),
          creditLimitMinor: _opt(d, 'credit_limit_minor', _iN), currency: _opt(d, 'currency', _s),
          isActive: _opt(d, 'is_active', _b), version: _opt(d, 'version', _i),
        ));
      case 'suppliers':
        await _write(_db.suppliers, id, exists, SuppliersCompanion(
          id: Value(id), name: _opt(d, 'name', _s), phone: _opt(d, 'phone', _sN),
          currency: _opt(d, 'currency', _s), isActive: _opt(d, 'is_active', _b),
          version: _opt(d, 'version', _i),
        ));
      case 'stock_movements':
        await _write(_db.stockMovements, id, exists, StockMovementsCompanion(
          id: Value(id), productId: _opt(d, 'product_id', _s), branchId: _opt(d, 'branch_id', _s),
          qtyDelta: _opt(d, 'qty_delta', _i), reason: _opt(d, 'reason', _s),
          occurredAt: _opt(d, 'occurred_at', _t),
        ));
      case 'sales':
        await _write(_db.sales, id, exists, SalesCompanion(
          id: Value(id), number: _opt(d, 'number', _s), branchId: _opt(d, 'branch_id', _s),
          shiftId: _opt(d, 'shift_id', _sN), customerId: _opt(d, 'customer_id', _sN),
          status: _opt(d, 'status', _s), currency: _opt(d, 'currency', _s),
          discountMinor: _opt(d, 'discount_minor', _i), subtotalMinor: _opt(d, 'subtotal_minor', _i),
          taxMinor: _opt(d, 'tax_minor', _i), totalMinor: _opt(d, 'total_minor', _i),
          paidMinor: _opt(d, 'paid_minor', _i), changeMinor: _opt(d, 'change_minor', _i),
          occurredAt: _opt(d, 'occurred_at', _t),
        ));
      case 'sale_lines':
        await _write(_db.saleLines, id, exists, SaleLinesCompanion(
          id: Value(id), saleId: _opt(d, 'sale_id', _s), productId: _opt(d, 'product_id', _s),
          name: _opt(d, 'name', _s), qtyMinor: _opt(d, 'qty_minor', _i),
          decimalPlaces: _opt(d, 'decimal_places', _i), unitPriceMinor: _opt(d, 'unit_price_minor', _i),
          unitCostMinor: _opt(d, 'unit_cost_minor', _i), lineTotalMinor: _opt(d, 'line_total_minor', _i),
          currency: _opt(d, 'currency', _s),
        ));
      case 'payments':
        await _write(_db.payments, id, exists, PaymentsCompanion(
          id: Value(id), saleId: _opt(d, 'sale_id', _s), method: _opt(d, 'method', _s),
          amountMinor: _opt(d, 'amount_minor', _i), currency: _opt(d, 'currency', _s),
          tenderedMinor: _opt(d, 'tendered_minor', _iN), changeMinor: _opt(d, 'change_minor', _iN),
        ));
      case 'customer_ledger':
        await _write(_db.customerLedger, id, exists, CustomerLedgerCompanion(
          id: Value(id), customerId: _opt(d, 'customer_id', _s), type: _opt(d, 'type', _s),
          amountMinor: _opt(d, 'amount_minor', _i), currency: _opt(d, 'currency', _s),
          refType: _opt(d, 'ref_type', _sN), refId: _opt(d, 'ref_id', _sN),
          occurredAt: _opt(d, 'occurred_at', _t), shiftId: _opt(d, 'shift_id', _sN),
          method: _opt(d, 'method', _sN),
        ));
      case 'shifts':
        await _write(_db.shifts, id, exists, ShiftsCompanion(
          id: Value(id), branchId: _opt(d, 'branch_id', _s), userId: _opt(d, 'user_id', _s),
          openedAt: _opt(d, 'opened_at', _t), openingFloatMinor: _opt(d, 'opening_float_minor', _i),
          closedAt: _opt(d, 'closed_at', _tN), countedCashMinor: _opt(d, 'counted_cash_minor', _iN),
          expectedCashMinor: _opt(d, 'expected_cash_minor', _iN),
          varianceMinor: _opt(d, 'variance_minor', _iN), status: _opt(d, 'status', _s),
          version: _opt(d, 'version', _i),
        ));
      case 'supplier_ledger':
        await _write(_db.supplierLedger, id, exists, SupplierLedgerCompanion(
          id: Value(id), supplierId: _opt(d, 'supplier_id', _s), type: _opt(d, 'type', _s),
          amountMinor: _opt(d, 'amount_minor', _i), currency: _opt(d, 'currency', _s),
          occurredAt: _opt(d, 'occurred_at', _t), shiftId: _opt(d, 'shift_id', _sN),
          method: _opt(d, 'method', _sN),
        ));
    }
  }
}
