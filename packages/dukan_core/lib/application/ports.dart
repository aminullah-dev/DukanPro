import '../domain/catalog.dart';
import '../domain/identity.dart';
import '../domain/inventory.dart';

/// Ports (interfaces the application layer needs) live here in `dukan_core`.
/// Concrete implementations live OUTWARD — in `dukan_data` (SQLite/Drift),
/// `dukan_sync`, or the server — so dependencies point inward. This is how
/// SQLite↔Postgres and offline↔online become a wiring change, not a rewrite.

abstract interface class StockMovementRepository {
  Future<void> append(StockMovement movement);
  Future<List<StockMovement>> forProduct(String productId, String branchId);
}

/// Identity persistence port. Implemented by dukan_data (Drift) on the client
/// and by a SQLAlchemy repository on the server. Soft-deleted rows are excluded.
abstract interface class UserRepository {
  Future<User?> findById(String id);
  Future<User?> findByUsername(String username);
  Future<void> save(User user);
  Future<bool> usernameTaken(String username);
  Future<int> activeOwnerCount();
}

/// Catalog persistence port. Soft-deleted rows are excluded from reads.
abstract interface class ProductRepository {
  Future<void> create(Product product, {List<Barcode> barcodes});
  Future<void> update(Product product);
  Future<Product?> findById(String id);
  Future<Product?> findByBarcode(String code);
  Future<List<Product>> list({String? search});
  Future<List<Barcode>> barcodesFor(String productId);
  Future<void> addBarcode(Barcode barcode);
  Future<bool> skuTaken(String sku);
  Future<bool> barcodeTaken(String code);
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
    this.txId,
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

  /// The local transaction it was written in: the server applies one
  /// transaction's ledger rows together or not at all (docs/sync-protocol.md).
  final String? txId;
}

/// The [OutboxOp.actorId] of automatic device writes no user performed (the
/// unit seed, `LocalCatalog.listUnits`): whoever syncs next may push them.
const systemActorId = 'system';

/// The client-side operation queue port.
abstract interface class SyncOutbox {
  Future<void> enqueue(OutboxOp op);
  Future<List<OutboxOp>> pending();
  Future<void> markAcked(String opId);
}
