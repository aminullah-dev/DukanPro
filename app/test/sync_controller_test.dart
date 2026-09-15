import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/sync/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

SessionActor _signedIn(String userId) => SessionActor(
      User(
        id: userId, username: userId, displayName: userId, status: UserStatus.active,
        assignments: const [], defaultBranchId: 'b1',
      ),
      'b1',
    );

Product _rice(String sku) =>
    Product(id: newId(), sku: sku, name: 'Rice', unitId: 'kg', sellPrice: Money(52000, 'AFN'));

ProviderContainer _container(AppDatabase db, FakeSyncClient client, SessionActor actor) {
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    syncClientProvider.overrideWithValue(client),
    deviceIdProvider.overrideWithValue('test-device'),
    autoSyncProvider.overrideWithValue(false),
    sessionActorProvider.overrideWithValue(actor),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('syncNow pushes pending ops, clears the count, and records the time', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final client = FakeSyncClient();
    final container = _container(db, client, _signedIn('u1'));

    // A local write leaves one pending op in the outbox.
    await LocalCatalog(db).createProduct(_rice('A1'), actorId: 'u1', deviceId: 'test-device');

    final ctrl = container.read(syncControllerProvider.notifier);
    await ctrl.refreshPending();
    expect(container.read(syncControllerProvider).pending, 1);

    await ctrl.syncNow();

    final status = container.read(syncControllerProvider);
    expect(status.pending, 0); // applied ⇒ acked
    expect(status.failed, isFalse);
    expect(status.lastSyncedAt, isNotNull);
    expect(client.pushed.single.aggregateType, 'products');
  });

  test('syncNow pushes only what the signed-in user recorded', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final client = FakeSyncClient();
    final container = _container(db, client, _signedIn('u2'));
    final catalog = LocalCatalog(db);
    await catalog.createProduct(_rice('A1'), actorId: 'u1', deviceId: 'test-device');
    await catalog.createProduct(_rice('B1'), actorId: 'u2', deviceId: 'test-device');

    await container.read(syncControllerProvider.notifier).syncNow();

    expect(client.pushed.map((o) => o.actorId), ['u2']);
    expect(container.read(syncControllerProvider).pending, 1); // u1's op waits for u1
  });

  test('ops the server rejects are counted for the status card', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final client = FakeSyncClient(
      outcome: (o) => PushResult(o.opId, OpOutcome.rejected, code: 'SYNC_FIELD_INVALID'),
    );
    final container = _container(db, client, _signedIn('u1'));
    await LocalCatalog(db).createProduct(_rice('A1'), actorId: 'u1', deviceId: 'test-device');

    await container.read(syncControllerProvider.notifier).syncNow();

    final status = container.read(syncControllerProvider);
    expect(status.rejected, 1);
    expect(status.pending, 0);
  });

  test('the counts follow the outbox without a sync, and issues can be set aside', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final client = FakeSyncClient(
      outcome: (op) => PushResult(op.opId, OpOutcome.conflict, code: 'PRODUCTS_ALREADY_EXISTS'),
    );
    final c = _container(db, client, _signedIn('u1'));
    c.read(syncControllerProvider);
    await LocalCatalog(db).createProduct(_rice('R1'), actorId: 'u1', deviceId: 'test-device');
    await pumpEventQueue();
    expect(c.read(syncControllerProvider).pending, 1); // no refresh needed: it is live

    await c.read(syncControllerProvider.notifier).syncNow();
    await pumpEventQueue();
    expect(c.read(syncControllerProvider).conflicts, 1);
    final issues = await c.read(syncIssuesProvider.future);
    expect((issues.single.table, issues.single.code), ('products', 'PRODUCTS_ALREADY_EXISTS'));

    await c.read(syncEngineProvider).dismiss(issues.single.opId);
    await pumpEventQueue();
    expect(c.read(syncControllerProvider).conflicts, 0);
  });
}
