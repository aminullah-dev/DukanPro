import '../shared/errors.dart';

/// Sample domain slice anchoring the layer and mirroring
/// `docs/domain/inventory.md`. Pure, framework-free, testable with zero
/// fixtures. Real catalog/sales aggregates land in Phases 2–3 alongside it.

enum StockReason { sale, purchase, adjustment, transferIn, transferOut, count, returned }

/// An append-only, immutable stock ledger entry. On-hand is **derived** by
/// summing these — never stored as a mutable running total.
final class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.branchId,
    required this.qtyDelta,
    required this.reason,
    required this.occurredAt,
  });

  final String id;
  final String productId;
  final String branchId;
  final int qtyDelta; // signed: negative for a sale
  final StockReason reason;
  final DateTime occurredAt;
}

/// On-hand for a product in a branch = Σ of its movement deltas.
int onHand(Iterable<StockMovement> movements) =>
    movements.fold(0, (sum, m) => sum + m.qtyDelta);

/// Produce the sale movement for selling [qty] units, enforcing the
/// single-device / online oversell rule. Offline partition handling (detect,
/// not prevent) is a sync concern; see `docs/sync-protocol.md`.
///
/// Raises:
/// - [ValidationError] `STOCK_INVALID_QTY` if qty <= 0
/// - [ConflictError] `STOCK_INSUFFICIENT` if qty > available
StockMovement sellFromStock({
  required String id,
  required String productId,
  required String branchId,
  required int qty,
  required int available,
  required DateTime at,
}) {
  if (qty <= 0) {
    throw ValidationError('STOCK_INVALID_QTY', {'qty': qty});
  }
  if (qty > available) {
    throw ConflictError(
        'STOCK_INSUFFICIENT', {'requested': qty, 'available': available});
  }
  return StockMovement(
    id: id,
    productId: productId,
    branchId: branchId,
    qtyDelta: -qty,
    reason: StockReason.sale,
    occurredAt: at,
  );
}
