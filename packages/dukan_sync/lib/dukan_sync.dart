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
  const PushResult(this.opId, this.outcome, {this.version, this.serverSeq, this.code, this.current});
  final String opId;
  final OpOutcome outcome;
  final int? version; // the master row's new version, when just applied
  final int? serverSeq; // the change-feed position of an applied op
  final String? code; // domain error code when rejected/conflict

  /// The server's row (a post-image) for a conflict: the server's state wins, and
  /// the device replaces its losing local copy with it.
  final Map<String, Object?>? current;
}

final class PullResult {
  const PullResult({
    required this.watermark,
    required this.changed,
    required this.tombstones,
    this.maxSeq,
    this.watermarkToken,
    this.scope,
    this.reset = false,
  });
  final int watermark;
  final List<Map<String, Object?>> changed;
  final List<String> tombstones; // ids soft-deleted upstream

  /// The feed's newest seq. A device already past it is pulling from a server
  /// restored from a backup, and starts over from the beginning.
  final int? maxSeq;

  /// Names the change at the watermark. Sent back as the next pull's
  /// `sinceToken`, it lets the server tell that its feed still holds what this
  /// device read.
  final String? watermarkToken;

  /// The pulling user's read scope. A different one (a role or a branch granted)
  /// means rows the old scope hid were skipped: the device reads the feed again.
  final String? scope;

  /// The server no longer holds the change at `sinceToken` (it was restored from a
  /// backup): the device reads the feed again from the start.
  final bool reset;
}

/// The client sync engine port. Implemented over an authoritative HTTP API
/// in Phase 6 (with an optional WebSocket/SSE change-nudge).
abstract interface class SyncClient {
  /// Push unacked ops in local_seq order. Server dedupes by opId (idempotent).
  Future<List<PushResult>> push(List<OutboxOp> ops);

  /// Pull changes since [sinceWatermark]; [sinceToken] is the token the previous
  /// pull returned for that watermark.
  Future<PullResult> pull({required int sinceWatermark, String? sinceToken});
}
