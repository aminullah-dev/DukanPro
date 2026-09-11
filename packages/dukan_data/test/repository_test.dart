import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

void main() {
  test('in-memory repo round-trips movements and derives on-hand', () async {
    final repo = InMemoryStockMovementRepository();
    final at = DateTime.utc(2026, 9, 11);
    await repo.append(StockMovement(
        id: newId(), productId: 'A1', branchId: 'B1', qtyDelta: 10,
        reason: StockReason.purchase, occurredAt: at));
    await repo.append(StockMovement(
        id: newId(), productId: 'A1', branchId: 'B1', qtyDelta: -3,
        reason: StockReason.sale, occurredAt: at));

    final movements = await repo.forProduct('A1', 'B1');
    expect(onHand(movements), 7);
  });

  test('outbox enqueues pending and marks acked', () async {
    final outbox = InMemorySyncOutbox();
    final op = OutboxOp(
      opId: newId(), aggregateType: 'sale', aggregateId: newId(),
      opType: 'settle', payload: const {'total': 520}, localSeq: 1,
      deviceId: 'dev-1', actorId: 'user-1', createdAt: DateTime.utc(2026, 9, 11),
    );
    await outbox.enqueue(op);
    expect((await outbox.pending()).length, 1);
    await outbox.markAcked(op.opId);
    expect((await outbox.pending()).isEmpty, isTrue);
  });
}
