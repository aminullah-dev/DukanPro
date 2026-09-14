import 'dart:async';

import 'package:dukan_data/dukan_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../composition.dart';
import '../../infrastructure/auth_api.dart' show AuthApiException, NetworkException;
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

/// Whether the device syncs on its own (after local writes and every few
/// minutes while someone is signed in). Tests turn it off.
final autoSyncProvider = Provider<bool>((ref) => true);

/// Drives the Sync control. The pending, conflict and rejected counts follow the
/// outbox live, so the badge is right after every sale; [syncNow] pushes then
/// pulls, then refreshes the local read models. The device also syncs on its own
/// a few seconds after a local write and every couple of minutes.
class SyncController extends Notifier<SyncStatus> {
  SyncEngine get _engine => ref.read(syncEngineProvider);

  static const afterWrite = Duration(seconds: 5);
  static const every = Duration(minutes: 2);

  Timer? _soon;

  @override
  SyncStatus build() {
    final counts = _engine.watchCounts().listen(_onCounts);
    final periodic = Timer.periodic(every, (_) => _auto());
    ref.onDispose(() {
      counts.cancel();
      periodic.cancel();
      _soon?.cancel();
    });
    return const SyncStatus();
  }

  void _onCounts(SyncCounts c) {
    final wrote = c.pending > state.pending;
    state = state.copyWith(pending: c.pending, conflicts: c.conflicts, rejected: c.rejected);
    if (wrote) {
      _soon?.cancel();
      _soon = Timer(afterWrite, _auto);
    }
  }

  void _auto() {
    if (ref.read(autoSyncProvider) && ref.read(sessionActorProvider) != null) unawaited(syncNow());
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
    var synced = false;
    try {
      // As the signed-in user: the server applies an op only under the token of
      // the user who recorded it, and each user pulls through their own scope.
      await _engine.syncNow(actorId: ref.read(sessionActorProvider)?.user.id);
      synced = true;
    } on NetworkException {
      // Offline: a failed sync; the outbox keeps everything.
    } on AuthApiException {
      // The server refused the request itself. A session that ended has already
      // sent the app to sign-in.
    } finally {
      // Whatever happened, never stay "syncing": that would block every later sync.
      state = state.copyWith(
        syncing: false,
        failed: !synced,
        lastSyncedAt: synced ? DateTime.now() : null,
      );
      if (synced) _refreshReadModels();
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

/// Ops the server conflicted or rejected, newest first; refetched as the
/// counts change.
final syncIssuesProvider = FutureProvider.autoDispose<List<SyncIssue>>((ref) {
  ref.watch(syncControllerProvider.select((s) => (s.conflicts, s.rejected)));
  return ref.read(syncEngineProvider).issues();
});

final syncControllerProvider =
    NotifierProvider<SyncController, SyncStatus>(SyncController.new);
