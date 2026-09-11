# Domain specification

These files are the **single source of truth** for DukanPro's business rules. Because the client (Dart) and server (Python) implement the domain in two languages, the rule lives **here as a specification with a test table**, and each language mirrors that table. **Divergence is a failing test, not a discovered bug** (per `platform-core` architecture guidance).

## How to read a spec

Each aggregate file has:

- **Purpose** — one sentence.
- **Entities & value objects** — the shape, in platform-neutral terms. All carry the standard record columns (`id, created_at, updated_at, deleted_at, created_by, updated_by, version`) unless noted.
- **Invariants** — rules the aggregate enforces itself. These are what domain code guards.
- **Error codes** — stable `<AGGREGATE>_<CONDITION>` codes raised when an invariant is violated.
- **Test table** — canonical cases; the same rows are implemented as unit tests in `packages/dukan_core/test/` and `server/tests/unit/`.
- **Audit** — which actions write an audit entry.
- **Sync class** — how each part behaves under the sync protocol (append-only ledger / mutable master / server-owned state).

## Aggregates

| File | Aggregate | Phase |
|---|---|---|
| [`identity-access.md`](identity-access.md) | Users, roles, permissions, sessions | 1, 7 |
| [`catalog.md`](catalog.md) | Products, variants, categories, units, barcodes, prices | 2 |
| [`inventory.md`](inventory.md) | Stock items, movements, counts, transfers | 2 |
| [`sales.md`](sales.md) | Sales, lines, payments, receipts, shifts | 3 |
| [`customers-debt.md`](customers-debt.md) | Customers, customer ledger, debt payments | 4 |
| [`purchasing.md`](purchasing.md) | Suppliers, purchase orders, goods receipts, supplier ledger | 4 |
| [`branches.md`](branches.md) | Branches, warehouses | 7 |
| [`read-models-sync-audit.md`](read-models-sync-audit.md) | Reporting read models, sync outbox, audit log | 5, 6, 10 |

## Cross-aggregate invariants

- **Money** is always `Money(amount_minor, currency)`; cross-currency arithmetic raises; exchange rate is stored with the transaction that used it.
- **Identity** is UUIDv7; **business numbers** are server-assigned and user-facing.
- **Quantities and balances are derived from append-only ledgers**, never stored as a mutable running total that a write could clobber.
- **Every action that changes money, stock, pricing, permissions, or deletes** writes an audit entry in the same transaction.
