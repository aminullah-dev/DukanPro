# Purchasing

**Purpose:** buy goods from suppliers, receive them into stock, track what the shop owes suppliers. (Phase 4.)

## Entities & value objects

- **Supplier** — `{ id, name, phone?, currency_default, is_active }`.
- **PurchaseOrder (PO)** — `{ id, business_number, supplier_id, branch_id, status(draft|sent|partially_received|received|closed|cancelled), lines:[POLine], currency }`.
- **POLine** — `{ id, product_id, qty_ordered, unit_cost(Money), qty_received }`.
- **GoodsReceipt (GRN)** — `{ id, business_number, po_id?, supplier_id, branch_id, lines:[{product_id, qty, unit_cost, landed_cost?}], occurred_at }`. Receiving **increments stock** at landed cost.
- **SupplierLedgerEntry** (append-only) — `{ id, supplier_id, entry_type(bill|payment|adjustment), amount(Money), ref_type, ref_id, occurred_at }`. Balance = Σ bills − Σ payments (positive = shop owes supplier).

## Invariants

1. A GoodsReceipt emits positive **StockMovements** (`reason=purchase`) at `unit_cost` (+ allocated landed cost), updating cost valuation in Catalog.
2. `Σ qty_received` across receipts for a PO line **cannot exceed `qty_ordered`** unless over-receipt is explicitly allowed (default: reject) → `PO_OVER_RECEIPT`.
3. A PO transitions `draft → sent → partially_received → received → closed`; illegal transitions are rejected.
4. Cost valuation method (last cost vs weighted average) is **configuration**, applied consistently; historical movements keep the cost they were received at (never retro-repriced).
5. Supplier balance is **derived** from the append-only supplier ledger.
6. Currencies: a PO/receipt/bill carries its own currency; supplier balance is per-currency; no implicit conversion.
7. Receiving stock needs `stock.adjust`; a receipt that **bills a supplier or carries a cost** also needs `purchase.cost` (owner, manager). Without it a receipt only moves stock and leaves the product's last cost alone.
8. A receipt's supplier must exist (`SUPPLIER_NOT_FOUND`).

## Error codes

| Code | When |
|---|---|
| `PO_OVER_RECEIPT` | received qty exceeds ordered (when disallowed) — context `sku, ordered, received, attempted` |
| `PO_ILLEGAL_TRANSITION` | invalid status change |
| `PURCHASE_CURRENCY_MISMATCH` | a bill or payment in a currency other than the supplier's (a receipt at a cost bills in the supplier's currency) |
| `GRN_EMPTY` | receiving with no lines |
| `SUPPLIER_NOT_FOUND` | receiving against an unknown supplier |
| `GRN_LINE_INVALID` | a received line with a quantity of zero or less, or a negative cost |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| receipt adds stock | PO line qty 10 @ cost 40 | receive 10 | stock +10, cost valuation updated |
| over-receipt | ordered 10, received 8 | receive 5 | `PO_OVER_RECEIPT` (ordered 10, received 8) |
| partial then full | ordered 10 | receive 6 then 4 | status partially_received → received |
| supplier balance | bill 4000, payment 1500 | read balance | `2500` owed to supplier |
| weighted avg cost | on_hand 10 @ 40, receive 10 @ 50 | valuation | avg 45 (if config=weighted_avg) |
| stock keeper bills | stock_keeper | receive with a supplier or a cost | `ACCESS_DENIED`; quantity only is allowed |

## Audit

`purchase.received` (stock + cost), `supplier.payment_recorded`, `po.status_changed`, `cost.valuation_changed` — all audited.

## Sync class

- Supplier / PO / POLine: **mutable master data** + **server-owned state machine** (PO status).
- GoodsReceipt's stock movements & SupplierLedgerEntry: **append-only ledger**.
- PO/GRN business numbers: **server-assigned** (leased ranges offline).
