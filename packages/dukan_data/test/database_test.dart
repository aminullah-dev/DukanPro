import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test('outbox persists pending ops in order and marks acked', () async {
    final outbox = DriftSyncOutbox(db);
    final op = OutboxOp(
      opId: newId(), aggregateType: 'sale', aggregateId: newId(), opType: 'settle',
      payload: const {'total': 520}, localSeq: 1, deviceId: 'd1', actorId: 'u1',
      createdAt: DateTime.utc(2026, 9, 11),
    );
    await outbox.enqueue(op);

    final pending = await outbox.pending();
    expect(pending.length, 1);
    expect(pending.first.opId, op.opId);
    expect(pending.first.payload['total'], 520);
    expect(pending.first.status, OutboxStatus.pending);

    await outbox.markAcked(op.opId);
    expect((await outbox.pending()).isEmpty, isTrue);
  });

  test('profile cache round-trips and upserts', () async {
    final store = ProfileStore(db);
    await store.save(
      userId: 'u1', username: 'owner', displayName: 'Amin', defaultBranchId: 'b1',
      branches: const [{'branch_id': 'b1', 'branch_name': 'Main', 'role_name': 'owner'}],
    );
    final p = await store.current();
    expect(p, isNotNull);
    expect(p!.username, 'owner');
    expect(p.defaultBranchId, 'b1');

    await store.clear();
    expect(await store.current(), isNull);
  });
}
