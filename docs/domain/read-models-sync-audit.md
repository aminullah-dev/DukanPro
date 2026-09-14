# Read models, Sync outbox, Audit

Cross-cutting concerns. Two of these are **not aggregates**: reporting is a set of queries, and the outbox/audit are infrastructure ledgers. (Phases 5, 6, 10.)

## Reporting read models (Phase 5)

Reports are **queries/DTOs, not domain aggregates.** "Overdue", "dashboard", "top seller" are UI/report concerns — never repository method names (a repository exposes data; predicates live in the query or domain).

| Read model | Derived from | Notes |
|---|---|---|
| Sales summary (day/shift/branch) | sales + payments ledger | business day is branch-local |
| Stock valuation | stock movements + cost | method = config (last / weighted avg) |
| Debtor aging | customer ledger | buckets 0–30 / 31–60 / 61+ days |
| Supplier balances | supplier ledger | per currency |
| Profit | what the day's settled sales took (after discounts) − the goods' cost snapshot; lines sold without a cost are counted (`unknown_cost_lines`) | cost read from valuation at sale time |
| Low-stock | derived on-hand vs reorder level | feeds notifications (Phase 9) |

Read models are **projections over append-only ledgers**, so they are always reconstructable and never the authoritative store.

## Sync outbox (Phase 6)

Infrastructure, not domain. Client-side table capturing intent operations; see [`../sync-protocol.md`](../sync-protocol.md) for the full protocol. Key point for domain authors: **a use case that changes state enqueues its operation in the same transaction as the local write** — the application layer owns this, the domain stays pure.

## Audit log (Phase 10 export; written from day one)

An audit entry is **not a log line** — it is an append-only business record, included in backups, admissible in a dispute.

| Field | |
|---|---|
| `id`, `occurred_at` | UTC |
| `actor_id`, `actor_role` | who |
| `action` | `sale.voided`, `stock.adjusted`, … |
| `entity_type`, `entity_id` | what |
| `before`, `after` | JSON diff of changed fields only |
| `origin` | client / api / sync / job |

**Written in the same transaction** as any change to money, stock quantity, pricing, permissions, license state, or deletion. An audit trail that can be missing when the write succeeded is worse than none, because it will be trusted.

**Sync writes are audited too.** Every op `/sync/push` applies writes one entry in the same transaction:
- `origin` is `sync`.
- `actor_id` / `actor_role` are the pushing user and their role in the row's branch.
- `after` carries a `_sync` block `{op_id, device_id, branch_id, recorded_by, recorded_at}`. `recorded_at` is the device's outbox time, kept for information only.

The actions are:
- `product.created`, `product.updated`, `product.price_changed`, `product.deactivated`
- `barcode.added`, `unit.created`, `customer.created`, `supplier.created`
- `stock.adjusted`, `stock.received`, `stock.sold`
- `sale.settled`, `sale.line_added`, `payment.recorded`
- `debt.charge_posted`, which flags `over_credit_limit`
- `debt.payment_recorded`, which flags `overpaid`
- `supplier.bill_posted`

Offline ledger entries still apply when they break a limit that would be enforced online; the flag is what the owner reviews. See [`../sync-protocol.md`](../sync-protocol.md).

## Test table (audit)

| Case | Given | Action | Expect |
|---|---|---|---|
| void writes audit | settled sale | void | audit `sale.voided` exists in same tx with before/after |
| price change audited | product price 50 | change to 60 | audit `product.price_changed` {before:50, after:60} |
| read is not audited | any | view report | no audit entry (reads are not audited) |
| audit append-only | existing entry | attempt edit/delete | rejected (append-only) |

## Sync class

Audit: **append-only ledger**, synced up to the server, never edited. Outbox: client-local, consumed by sync.

## Quantities in reports

- Low stock counts active, stock-tracked products at or below 5 whole units of their unit (5 kg is 5000 g).
- Top sellers rank by revenue, since 2 kg of rice and 500 soaps are not comparable counts. Each carries its quantity with the unit's decimal places and name, and shows as "1.500 kg".
