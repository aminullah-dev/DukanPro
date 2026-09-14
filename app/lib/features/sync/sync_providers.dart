import 'package:dukan_data/dukan_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../composition.dart';
import '../../infrastructure/auth_api.dart' show NetworkException;
import '../auth/providers.dart';
import '../auth/session.dart';
import '../catalog/catalog_providers.dart';
import '../customers/customers_providers.dart';
import '../dashboard/dashboard_screen.dart' show dashboardProvider;

/// The sync engine, wired from the Drift database, the (overridden) sync
/// client, and this device's id. See docs/sync-protocol.md.
final syncEngineProvider = Provider<SyncEngine>(
  (ref) => SyncEngine(
    ref.watch(databaseProvider),
    ref.watch(syncClientProvider),
    deviceId: ref.watch(deviceIdProvider),
  ),
);

/// Observable sync status for the UI.
class SyncStatus {
  const SyncStatus({
    this.pending = 0,
    this.conflicts = 0,
    this.rejected = 0,
    this.syncing = false,
    this.lastSyncedAt,
    this.failed = false,
  });
  final int pending;
  final int conflicts;
  final int rejected; // ops the server refused: their local effect is not on the server
  final bool syncing;
  final DateTime? lastSyncedAt;
  final bool failed;

  SyncStatus copyWith({
    int? pending,
    int? conflicts,
    int? rejected,
    bool? syncing,
    DateTime? lastSyncedAt,
    bool? failed,
  }) =>
      SyncStatus(
        pending: pending ?? this.pending,
        conflicts: conflicts ?? this.conflicts,
        rejected: rejected ?? this.rejected,
        syncing: syncing ?? this.syncing,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        failed: failed ?? this.failed,
      );
}

/// Drives the Sync control: exposes the pending-op count + last-synced time and
/// a [syncNow] that pushes then pulls, then refreshes the local read models.
class SyncController extends Notifier<SyncStatus> {
  SyncEngine get _engine => ref.read(syncEngineProvider);

  @override
  SyncStatus build() {
    Future.microtask(refreshPending);
    return const SyncStatus();
  }

  Future<void> refreshPending() async {
    final pending = await _engine.pendingCount();
    final conflicts = await _engine.conflictCount();
    final rejected = await _engine.rejectedCount();
    state = state.copyWith(pending: pending, conflicts: conflicts, rejected: rejected);
  }

  Future<void> syncNow() async {
    if (state.syncing) return;
    state = state.copyWith(syncing: true, failed: false);
    try {
      // As the signed-in user: the server applies an op only under the token of
      // the user who recorded it, and each user pulls through their own scope.
      await _engine.syncNow(actorId: ref.read(sessionActorProvider)?.user.id);
      state = state.copyWith(syncing: false, lastSyncedAt: DateTime.now(), failed: false);
      _refreshReadModels();
    } on NetworkException {
      state = state.copyWith(syncing: false, failed: true);
    } finally {
      await refreshPending();
    }
  }

  /// Invalidate the local read models so rows pulled from the server appear.
  void _refreshReadModels() {
    ref.invalidate(productsProvider);
    ref.invalidate(unitsProvider);
    ref.invalidate(customersProvider);
    ref.invalidate(suppliersProvider);
    ref.invalidate(dashboardProvider);
  }
}

final syncControllerProvider =
    NotifierProvider<SyncController, SyncStatus>(SyncController.new);
