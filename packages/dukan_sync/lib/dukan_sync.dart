/// DukanPro sync engine contracts. Implementation lands in Phase 6; these
/// types fix the protocol so every Phase 1–5 write is already sync-shaped.
/// See `docs/sync-protocol.md`.
library;

import 'package:dukan_core/dukan_core.dart';

/// How an aggregate behaves under sync. Getting this right removes most
/// conflicts (append-only ledgers never conflict).
enum ConflictClass {
  /// stock movements, payments, debt/supplier ledger entries, audit — all ops
  /// apply; balances are derived. No conflict possible.
  appendOnlyLedger,

  /// product, customer, supplier profiles — optimistic `version`; a stale
  /// base_version raises a conflict to reconcile.
  mutableMaster,

  /// sale/PO status — server-authoritative state machine; illegal transitions
  /// are rejected.
  serverOwnedState,
}

/// Result of applying one pushed operation on the server.
enum OpOutcome { applied, conflict, rejected }

final class PushResult {
  const PushResult(this.opId, this.outcome, {this.version, this.code});
  final String opId;
  final OpOutcome outcome;
  final int? version; // new authoritative version when applied
  final String? code; // domain error code when rejected/conflict
}

final class PullResult {
  const PullResult({required this.watermark, required this.changed, required this.tombstones});
  final int watermark;
  final List<Map<String, Object?>> changed;
  final List<String> tombstones; // ids soft-deleted upstream
}

/// The client sync engine port. Implemented over an authoritative HTTP API
/// in Phase 6 (with an optional WebSocket/SSE change-nudge).
abstract interface class SyncClient {
  /// Push unacked ops in local_seq order. Server dedupes by opId (idempotent).
  Future<List<PushResult>> push(List<OutboxOp> ops);

  /// Pull changes since [sinceWatermark].
  Future<PullResult> pull({required int sinceWatermark});
}
