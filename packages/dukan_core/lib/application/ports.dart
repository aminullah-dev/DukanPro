import '../domain/inventory.dart';

/// Ports (interfaces the application layer needs) live here in `dukan_core`.
/// Concrete implementations live OUTWARD — in `dukan_data` (SQLite/Drift),
/// `dukan_sync`, or the server — so dependencies point inward. This is how
/// SQLite↔Postgres and offline↔online become a wiring change, not a rewrite.

abstract interface class StockMovementRepository {
  Future<void> append(StockMovement movement);
  Future<List<StockMovement>> forProduct(String productId, String branchId);
}

/// Status of an operation in the offline queue.
enum OutboxStatus { pending, sent, acked, conflict, rejected }

/// One entry in the offline operation queue. See `docs/sync-protocol.md`.
/// Written in the same local transaction as the optimistic state change.
final class OutboxOp {
  const OutboxOp({
    required this.opId,
    required this.aggregateType,
    required this.aggregateId,
    required this.opType,
    required this.payload,
    required this.localSeq,
    required this.deviceId,
    required this.actorId,
    required this.createdAt,
    this.baseVersion,
    this.status = OutboxStatus.pending,
  });

  final String opId; // UUIDv7 — also the idempotency key
  final String aggregateType;
  final String aggregateId;
  final String opType;
  final Map<String, Object?> payload;
  final int localSeq;
  final String deviceId;
  final String actorId;
  final DateTime createdAt;
  final int? baseVersion; // for mutable-master-data conflict detection
  final OutboxStatus status;
}

/// The client-side operation queue port.
abstract interface class SyncOutbox {
  Future<void> enqueue(OutboxOp op);
  Future<List<OutboxOp>> pending();
  Future<void> markAcked(String opId);
}
