# Sales / POS

**Purpose:** ring up a sale, take payment (cash / partial / credit), print a receipt. The heart of the app. (Phase 3.)

## Entities & value objects

- **Sale** — `{ id, business_number, branch_id, shift_id, customer_id?, status(open|settled|voided|refunded), lines:[SaleLine], discount(Money|percent), currency, subtotal, tax_total, total, paid_total, balance_due, occurred_at }`.
- **SaleLine** — `{ id, product_id, variant_id?, qty, unit_price(Money snapshot), line_discount, tax_rate, line_tax, line_total }`. `unit_price` is **snapshotted** at sale time.
- **Payment** (append-only) — `{ id, sale_id, method(cash|card|credit|transfer), amount(Money), tendered?, change?, occurred_at }`.
- **Receipt** — rendered document (per-locale template, embeds fonts, both calendars).
- **Shift / RegisterSession** — `{ id, branch_id, user_id, opened_at, opening_float(Money), closed_at?, closing_count?, expected_cash, variance }`.

## Invariants

1. **Tax is computed per line, then summed** — never on the subtotal (auditors check; the two differ).
2. `total = Σ line_total − sale_discount`; `balance_due = total − paid_total`.
3. A sale **settles** only when `paid_total ≥ total` **or** the unpaid remainder is placed on the customer's **debt ledger** (credit sale → requires a `customer_id` and `debt.write`/credit permission + within credit limit; see `customers-debt.md`).
4. Settling a stock-tracked sale emits **one** set of negative StockMovements (idempotent — a replay does not double-decrement).
5. `unit_price` is **snapshotted**; a later catalog price change never alters a past sale.
6. A settled sale is **immutable**; corrections are a **void** (reverses stock + payments + ledger) or a **refund** (new negative sale referencing the original). No in-place edits.
7. Change is computed for cash tender; over-tender yields `change`, never a negative payment.
8. Payments are append-only; you cannot delete a payment, only void the sale or record a refund.

## Error codes

| Code | When |
|---|---|
| `SALE_ALREADY_SETTLED` | mutating lines of a settled sale |
| `SALE_EMPTY` | settling a sale with no lines |
| `SALE_CREDIT_NO_CUSTOMER` | credit remainder with no customer |
| `SALE_OVER_CREDIT_LIMIT` | credit remainder exceeds customer limit → (see `customers-debt.md`) |
| `SALE_CURRENCY_MISMATCH` | payment currency ≠ sale currency (no implicit conversion) |
| `SHIFT_NOT_OPEN` | ringing a sale with no open shift (when shifts required) |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| tax per line | 2 lines, 10% each | settle | `tax_total = Σ line_tax`, not 10% of subtotal |
| exact cash | total=500, tender=500 | pay cash | settled, change=0 |
| over tender | total=500, tender=600 | pay cash | settled, change=100 |
| partial then credit | total=500, cash=300, customer set | settle on credit | balance 200 → customer ledger; settled |
| credit no customer | total=500, cash=300, no customer | settle | `SALE_CREDIT_NO_CUSTOMER` |
| price snapshot | line at price 50 | later catalog price→60; reread sale | line still 50 |
| void reverses | settled sale with stock + payment | void | stock movements reversed, payments reversed, audited |
| settle decrements once | stock-tracked sale | settle, then replay settle op | stock −qty exactly once |
| currency mismatch | sale AFN | pay USD | `SALE_CURRENCY_MISMATCH` |

## Audit

`sale.settled`, `sale.voided`, `sale.refunded`, `payment.recorded`, `discount.applied`, `shift.opened`, `shift.closed` (with variance) — all audited (money + stock).

## Sync class

- Sale header / status: **server-owned state machine** (open→settled→voided/refunded).
- SaleLine: part of the Sale aggregate, settled atomically with it.
- Payment & the stock movements it triggers: **append-only ledger**.
- Business number: **server-assigned** (leased ranges for offline — see `sync-protocol.md`).
