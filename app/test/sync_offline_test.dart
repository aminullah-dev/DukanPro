// A sync that cannot reach the server keeps every change: the outbox holds it,
// the status says the sync failed, and the next sync that gets through sends it.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/sync/sync_providers.dart';
import 'package:dukanpro/infrastructure/auth_api.dart' show NetworkException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// The server out of reach until [offline] is turned off.
class _Unreachable extends FakeSyncClient {
  bool offline = true;

  @override
  Future<List<PushResult>> push(List<OutboxOp> ops) async {
    if (offline) throw const NetworkException();
    return super.push(ops);
  }
}

void main() {
  test('offline, a sync fails and keeps every change; back online, it sends them', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final client = _Unreachable();
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      syncClientProvider.overrideWithValue(client),
      deviceIdProvider.overrideWithValue('test-device'),
      autoSyncProvider.overrideWithValue(false),
      sessionActorProvider.overrideWithValue(SessionActor(
        User(
          id: 'u1', username: 'u1', displayName: 'u1', status: UserStatus.active,
          assignments: const [], defaultBranchId: 'b1',
        ),
        'b1',
      )),
    ]);
    addTearDown(container.dispose);
    await LocalCatalog(db).createProduct(
      Product(id: newId(), sku: 'A1', name: 'Rice', unitId: 'kg', sellPrice: Money(52000, 'AFN')),
      actorId: 'u1', deviceId: 'test-device',
    );
    final sync = container.read(syncControllerProvider.notifier);

    await sync.syncNow();
    var status = container.read(syncControllerProvider);
    expect((status.failed, status.syncing, status.pending), (true, false, 1));
    expect(client.pushed, isEmpty);

    client.offline = false;
    await sync.syncNow();
    status = container.read(syncControllerProvider);
    expect((status.failed, status.pending), (false, 0));
    expect(client.pushed.single.aggregateType, 'products');
  });
}
