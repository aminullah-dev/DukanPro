import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart';

import '../database.dart';
import 'sync_recorder.dart';

/// What a shift took, by tender, and what its drawer should hold: the opening
/// float, the cash of its settled sales and the debts collected in it in cash.
/// Card and transfer money never reaches the drawer; a voided sale's cash went
/// back to the customer.
final class ShiftSummary {
  const ShiftSummary({
    required this.openingFloatMinor,
    required this.cashSalesMinor,
    required this.cardSalesMinor,
    required this.transferSalesMinor,
    required this.cashCollectedMinor,
    required this.otherCollectedMinor,
    this.cashPaidOutMinor = 0,
  });
  final int openingFloatMinor;
  final int cashSalesMinor;
  final int cardSalesMinor;
  final int transferSalesMinor;
  final int cashCollectedMinor;
  final int otherCollectedMinor;

  /// Cash paid out of the drawer to suppliers.
  final int cashPaidOutMinor;

  int get expectedCashMinor => openingFloatMinor + cashSalesMinor + cashCollectedMinor - cashPaidOutMinor;
}

/// A till's shifts: opened with a float, closed with the counted cash (the
/// Z-report). A shift is its seller's own and syncs as a versioned row; the
/// server works out its own expected cash from what reached it.
final class LocalShifts {
  LocalShifts(this._db) : _rec = SyncRecorder(_db);
  final AppDatabase _db;
  final SyncRecorder _rec;

  /// The open shift of [userId] in [branchId] that this till opened, if any. A
  /// seller may have another drawer open on another till (the server flags it);
  /// this till's sales go into its own. Without [deviceId], the newest of them.
  Future<ShiftRow?> current({required String branchId, required String userId, String? deviceId}) async {
    final open = await (_db.select(_db.shifts)
          ..where((t) =>
              t.branchId.equals(branchId) & t.userId.equals(userId) & t.status.equals('open') & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.openedAt)]))
        .get();
    for (final shift in open) {
      if (deviceId == null || await _openedHere(shift.id, deviceId)) return shift;
    }
    return null;
  }

  /// Whether this till opened [shiftId]: its insert is in this device's outbox.
  Future<bool> _openedHere(String shiftId, String deviceId) async => (await (_db.select(_db.outboxEntries)
            ..where((t) =>
                t.aggregateType.equals('shifts') &
                t.aggregateId.equals(shiftId) &
                t.opType.equals('insert') &
                t.deviceId.equals(deviceId))
            ..limit(1))
          .get())
      .isNotEmpty;

  /// Opens [userId]'s shift in [branchId] with [openingFloatMinor] in the
  /// drawer. One at a time per seller on this till (`SHIFT_ALREADY_OPEN`).
  Future<ShiftRow> open({
    required String branchId,
    required String userId,
    required int openingFloatMinor,
    required String deviceId,
  }) async {
    assertShiftCashValid(amountMinor: openingFloatMinor);
    final id = newId();
    await _db.transaction(() async {
      if (await current(branchId: branchId, userId: userId, deviceId: deviceId) != null) {
        throw ConflictError('SHIFT_ALREADY_OPEN', const {});
      }
      await _db.into(_db.shifts).insert(ShiftsCompanion.insert(
            id: id, branchId: branchId, userId: userId,
            openingFloatMinor: Value(openingFloatMinor), createdBy: Value(userId), updatedBy: Value(userId),
          ));
      await _rec.record(table: 'shifts', rowId: id, op: 'insert', data: {
        'branch_id': branchId, 'user_id': userId, 'opening_float_minor': openingFloatMinor, 'status': 'open',
      }, actorId: userId, deviceId: deviceId);
    });
    return (_db.select(_db.shifts)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<ShiftSummary> summary(ShiftRow shift) async {
    int total(Iterable<int> amounts) => amounts.fold(0, (a, b) => a + b);
    final sales = await (_db.select(_db.sales)
          ..where((t) => t.shiftId.equals(shift.id) & t.status.equals('settled') & t.deletedAt.isNull()))
        .get();
    final payments = await (_db.select(_db.payments)
          ..where((t) => t.saleId.isIn([for (final s in sales) s.id]) & t.deletedAt.isNull()))
        .get();
    int taken(PaymentMethod m) => total(payments.where((p) => p.method == m.name).map((p) => p.amountMinor));
    final collected = await (_db.select(_db.customerLedger)
          ..where((t) => t.shiftId.equals(shift.id) & t.type.equals('payment') & t.deletedAt.isNull()))
        .get();
    final paidOut = await (_db.select(_db.supplierLedger)
          ..where((t) =>
              t.shiftId.equals(shift.id) & t.type.equals('payment') & t.method.equals('cash') & t.deletedAt.isNull()))
        .get();
    return ShiftSummary(
      openingFloatMinor: shift.openingFloatMinor,
      cashSalesMinor: taken(PaymentMethod.cash),
      cardSalesMinor: taken(PaymentMethod.card),
      transferSalesMinor: taken(PaymentMethod.transfer),
      cashCollectedMinor: total(collected.where((e) => e.method == 'cash').map((e) => e.amountMinor)),
      otherCollectedMinor: total(collected.where((e) => e.method != 'cash').map((e) => e.amountMinor)),
      cashPaidOutMinor: total(paidOut.map((e) => e.amountMinor)),
    );
  }

  /// Closes [shift] with the cash counted in the drawer; the variance is that
  /// less the expected cash (a shortage is negative).
  Future<ShiftRow> close(
    ShiftRow shift, {
    required int countedCashMinor,
    required String actorId,
    required String deviceId,
  }) async {
    assertShiftCashValid(amountMinor: countedCashMinor);
    if (shift.status != 'open') throw ConflictError('SHIFT_ALREADY_CLOSED', {'shift_id': shift.id});
    final expected = (await summary(shift)).expectedCashMinor;
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.shifts)..where((t) => t.id.equals(shift.id))).write(ShiftsCompanion(
            status: const Value('closed'), closedAt: Value(now), countedCashMinor: Value(countedCashMinor),
            expectedCashMinor: Value(expected), varianceMinor: Value(countedCashMinor - expected),
            updatedBy: Value(actorId), updatedAt: Value(now), version: Value(shift.version + 1),
          ));
      await _rec.record(
        table: 'shifts', rowId: shift.id, op: 'update', baseVersion: shift.version,
        data: {'status': 'closed', 'counted_cash_minor': countedCashMinor}, actorId: actorId, deviceId: deviceId,
      );
    });
    return (_db.select(_db.shifts)..where((t) => t.id.equals(shift.id))).getSingle();
  }
}
