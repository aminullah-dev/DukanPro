import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/sync/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('syncNow pushes pending ops, clears the count, and records the time', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final client = FakeSyncClient();
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      syncClientProvider.overrideWithValue(client),
      deviceIdProvider.overrideWithValue('test-device'),
    ]);
    addTearDown(container.dispose);

    // A local write leaves one pending op in the outbox.
    await LocalCatalog(db).createProduct(
      Product(id: newId(), sku: 'A1', name: 'Rice', unitId: 'kg', sellPrice: Money(52000, 'AFN')),
      actorId: 'u1', deviceId: 'test-device',
    );

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
}
