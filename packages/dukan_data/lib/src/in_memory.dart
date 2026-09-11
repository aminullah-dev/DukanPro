/// In-memory implementations of dukan_core ports. Useful for tests and as the
/// Phase 0 placeholder; the Drift-backed stores in database.dart are used by
/// the app.
library;

import 'package:dukan_core/dukan_core.dart';

final class InMemoryStockMovementRepository implements StockMovementRepository {
  final List<StockMovement> _movements = [];

  @override
  Future<void> append(StockMovement movement) async => _movements.add(movement);

  @override
  Future<List<StockMovement>> forProduct(String productId, String branchId) async =>
      _movements
          .where((m) => m.productId == productId && m.branchId == branchId)
          .toList(growable: false);
}

final class InMemorySyncOutbox implements SyncOutbox {
  final List<OutboxOp> _ops = [];

  @override
  Future<void> enqueue(OutboxOp op) async => _ops.add(op);

  @override
  Future<List<OutboxOp>> pending() async =>
      _ops.where((o) => o.status == OutboxStatus.pending).toList(growable: false);

  @override
  Future<void> markAcked(String opId) async {
    final i = _ops.indexWhere((o) => o.opId == opId);
    if (i < 0) throw NotFoundError('OUTBOX_OP_NOT_FOUND', {'opId': opId});
    final o = _ops[i];
    _ops[i] = OutboxOp(
      opId: o.opId, aggregateType: o.aggregateType, aggregateId: o.aggregateId,
      opType: o.opType, payload: o.payload, localSeq: o.localSeq,
      deviceId: o.deviceId, actorId: o.actorId, createdAt: o.createdAt,
      baseVersion: o.baseVersion, status: OutboxStatus.acked,
    );
  }
}
