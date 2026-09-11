/// DukanPro data layer — implements `dukan_core` ports.
///
/// Phase 0: in-memory implementations (so `app → data → core` is real and
/// testable). Phase 1 replaces these with Drift (SQLite) repositories plus the
/// outbox table, without changing the port signatures in `dukan_core`.
library;

import 'package:dukan_core/dukan_core.dart';

/// In-memory stock movement store (placeholder for the Drift repository).
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

/// In-memory outbox (placeholder for the Drift-backed operation queue).
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
    // Immutable op record — replace rather than mutate.
    final o = _ops[i];
    _ops[i] = OutboxOp(
      opId: o.opId, aggregateType: o.aggregateType, aggregateId: o.aggregateId,
      opType: o.opType, payload: o.payload, localSeq: o.localSeq,
      deviceId: o.deviceId, actorId: o.actorId, createdAt: o.createdAt,
      baseVersion: o.baseVersion, status: OutboxStatus.acked,
    );
  }
}
