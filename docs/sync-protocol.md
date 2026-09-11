# Sync protocol (offline-first)

Status: **design, Phase 0.** Implementation begins Phase 6; the client outbox table and interfaces are scaffolded in Phase 0/1 so every write is sync-ready from the start.

## Principles

1. **Offline-first.** Every operation succeeds locally with no network. The UI never blocks on the server.
2. **Server authoritative, client optimistic.** The client applies an optimistic local effect and records an intent; the server is the source of truth and may reconcile.
3. **Intent operations, not row diffs.** The client records *what the user did* (a command), not a snapshot diff. This is what makes money/stock merges correct.
4. **Idempotent, exactly-once effect.** Every operation carries a client-generated `op_id` (UUIDv7) that is also its idempotency key. Replays are no-ops that return the original result.
5. **Identity never renumbers.** Records use client-generated **UUIDv7**. Only user-facing **business numbers** are server-assigned.

## Local operation queue (outbox)

Each client write appends an operation to a local `outbox` table **inside the same SQLite transaction** as the optimistic state change (so the two can never diverge):

| Field | Meaning |
|---|---|
| `op_id` | UUIDv7 — the idempotency key |
| `aggregate_type` | `sale`, `stock_movement`, `payment`, `product`, `customer`, … |
| `aggregate_id` | UUIDv7 of the target aggregate |
| `op_type` | `create` / `append` / `update` / `void` / … (domain verb) |
| `payload` | JSON command data |
| `base_version` | version the client read (for mutable aggregates) |
| `local_seq` | monotonic per-device sequence (ordering) |
| `device_id` | installation id |
| `actor_id` | user id |
| `created_at` | UTC |
| `status` | `pending` / `sent` / `acked` / `conflict` / `rejected` |

## Push

1. Client sends unacked operations **in `local_seq` order**.
2. Server, per operation, in a transaction: **dedupe by `op_id`** → if seen, return the stored result; else validate domain invariants, apply, record `op_id`, assign a global `server_seq`.
3. Server returns per-op `{op_id, result: applied|conflict|rejected, version?, code?}`.
4. Client marks `acked`, or handles `conflict`/`rejected`.

## Pull

1. Client requests changes since its last `server_watermark` (a monotonic server sequence).
2. Server returns changed records + **tombstones** (soft deletes) + a new watermark.
3. Client applies them, reconciling against any still-pending local optimistic state.

## Conflict policy — by aggregate class

This classification is the core of the design. **Get the class right and most conflicts disappear.**

| Class | Examples | Policy |
|---|---|---|
| **Append-only ledger** | stock movements, payments, debt entries, audit | **No conflict possible.** All operations apply; balances and on-hand are **derived** by summing the ledger. Two clerks selling the same SKU offline both append a decrement; the server applies both. This is why quantities/money are safe offline. |
| **Mutable master data** | product name/price, customer profile | Optimistic `version`. A stale `base_version` → `ConflictError` (`<AGGREGATE>_VERSION_CONFLICT`). Client re-reads; non-overlapping fields auto-merge, overlapping fields surface to the user. |
| **Server-owned state machine** | sale status, PO status | Server-authoritative transitions. Illegal transitions are `rejected` with a domain code; the client rolls back its optimistic state. |

**Never** apply last-write-wins to a quantity or a monetary amount.

## Oversell under partition (accepted reality)

Append-only stock means two offline tills can jointly drive on-hand negative. This is **detected, not prevented** (prevention is impossible under partition). On sync the server flags negative on-hand for the affected SKU/branch and raises it in reports/notifications for reconciliation. Single-device and online operation enforce stock limits up front.

## Business numbers under offline

Legal invoice numbers must be gap-free per product-year. Two candidate schemes — decision below:

- **A. Provisional → final.** Offline sale shows a provisional marker (e.g. `INV-LOCAL-…`); the server assigns the final `INV-2026-xxxxx` on sync. Simple, but the printed offline receipt lacks the final number.
- **B. Server-leased ranges (chosen).** Each device leases a block of numbers from the server when online (e.g. 5000–5099). Offline sales draw from the lease, so the printed receipt carries its final number immediately. Unused numbers in a returned lease are voided with an audit note to keep the sequence explainable to auditors.

**Decision: B (server-leased ranges)**, with A as the fallback when a device has never been online to obtain a lease.

## Transport

- HTTPS/JSON REST for push/pull. Auth via bearer token (access + refresh).
- Optional **WebSocket/SSE change-nudge** so online devices pull promptly instead of polling.
- Exponential backoff; sync triggered on app foreground/resume and after each local write when online. **No dependency on long background execution** (iOS limits).

## Testing

- Property/contract tests for idempotency (replay = no-op), ordering, and tombstone application.
- A **conflict test matrix** per aggregate class, mirrored in Dart and Python.
- Partition simulations: two devices offline → diverge → sync → assert derived balances equal the sum of all ledger ops.
