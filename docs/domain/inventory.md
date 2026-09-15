# Inventory

**Purpose:** how much of each product is on hand, where, and why it changed. (Phase 2.)

## Entities & value objects

- **StockMovement** (append-only ledger) — `{ id, product_id, variant_id?, branch_id, qty_delta(signed), reason(sale|purchase|adjustment|transfer_in|transfer_out|count|return), ref_type, ref_id, unit_cost?(Money), occurred_at }`. **Immutable once written.**
- **StockItem** (derived view) — `{ product_id, variant_id?, branch_id, on_hand }` where `on_hand = Σ qty_delta` over non-deleted movements for that product×branch. Not an authoritative stored total.
- **StockCount** — `{ id, branch_id, lines:[{product_id, counted_qty}], status(draft|posted) }`. Posting a count emits adjustment movements to reconcile counted vs derived on-hand.
- **Transfer** — `{ id, from_branch_id, to_branch_id, lines:[{product_id, qty}], status }`. Posting emits paired `transfer_out`/`transfer_in` movements.

## Invariants

1. **On-hand is derived** by summing movements — never stored as a mutable running total. (This is what makes concurrent offline sales safe; see `sync-protocol.md`.)
2. A StockMovement is **append-only and immutable**; corrections are new compensating movements, never edits.
3. For a stock-tracked product, a sale, purchase receipt, transfer, or count post **must** create movements; a product with `track_stock=false` creates none on any path (device or server sale, receipt, adjustment), and a synced movement for one is refused (`PRODUCT_NOT_STOCK_TRACKED`).
4. **Single-device / online:** a sale that would drive on-hand below zero raises `STOCK_INSUFFICIENT` before committing (`POST /sales`: lines of one product count together, products without stock tracking are not counted, and two online sales of one product take turns). **Under offline partition:** oversell is *detected on sync*, not prevented (flagged for reconciliation).
5. Transfer quantities must be positive; a transfer cannot exceed source on-hand at post time (single-device rule).
6. `unit_cost` on purchase/return movements feeds cost valuation; sale movements carry no cost (cost is read from valuation).

## Error codes

| Code | When |
|---|---|
| `STOCK_INSUFFICIENT` | on-hand would go negative (single-device/online) — context: `sku, requested, available` |
| `STOCK_MOVEMENT_IMMUTABLE` | attempt to edit/delete a posted movement |
| `STOCK_COUNT_ALREADY_POSTED` | re-posting a posted count |
| `TRANSFER_INVALID_QTY` | non-positive or over-available transfer qty |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| on-hand sums ledger | +10 purchase, −3 sale | read on_hand | `7` |
| oversell online | on_hand=2 | sell 5 (online) | `STOCK_INSUFFICIENT` (available=2) |
| movement immutable | posted movement M | edit M.qty | `STOCK_MOVEMENT_IMMUTABLE` |
| count adjustment | derived=7, counted=6 | post count | adjustment movement −1; on_hand=6 |
| transfer pairs | B1 on_hand=10 | transfer 4 → B2 | B1=6, B2=+4 (paired movements) |
| untracked product | product track_stock=false | sell 3 | no movements, sale ok |

## Audit

`stock.adjusted`, `stock.count_posted`, `stock.transferred` — all audited (stock quantity changes). Sale/purchase-driven movements are audited via their parent sale/purchase.

## Sync class

StockMovement: **append-only ledger** — no conflicts; all ops apply; on-hand re-derives. StockCount/Transfer: **server-owned state machine** for their `status`; their emitted movements are ledger appends.
