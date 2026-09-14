# Customers & Debt

**Purpose:** track customers and the credit (nasia / قرض) they owe. (Phase 4.)

## Entities & value objects

- **Customer** — `{ id, name, phone?, branch_id?, credit_limit(Money|none), is_active }`.
- **CustomerLedgerEntry** (append-only) — `{ id, customer_id, entry_type(charge|payment|adjustment|opening), amount(Money, signed by convention), ref_type(sale|debt_payment|manual), ref_id, occurred_at, note? }`.
- **Balance** (derived) — `balance = Σ charges − Σ payments` over the ledger. Positive = customer owes the shop.
- **DebtPayment** — `{ id, customer_id, amount(Money), method, allocated_to:[sale_id]?, occurred_at }`. Emits a `payment` ledger entry.

## Invariants

1. **Balance is derived** from the append-only ledger — never a stored mutable total.
2. A credit sale posts a `charge` entry for the unpaid remainder (in the sale's currency). The ledger is **per currency**; a customer may owe AFN and USD separately (no implicit conversion).
3. A credit sale is rejected if it would push the customer's balance above `credit_limit` (when a limit is set) → `SALE_OVER_CREDIT_LIMIT` (raised in Sales, enforced against this balance).
4. A DebtPayment cannot exceed the outstanding balance in that currency → `DEBT_OVERPAYMENT` (unless an explicit over-payment/credit-balance is allowed by config; default: reject).
5. Debt write-off is an `adjustment` entry requiring `debt.write_off` permission and is always audited.
6. Ledger entries are append-only and immutable; corrections are compensating entries.
7. **Credit is a manager's decision.** Setting any credit limit other than 0 (none means unlimited) needs `customer.credit` (owner, manager); a limit is never negative (`CUSTOMER_CREDIT_LIMIT_INVALID`). A customer a cashier creates offline syncs with limit 0, and its audit entry keeps the requested limit. A manager changes the limit later from the customers screen (a sync `customers` update) or with `PUT /customers/{id}/credit-limit` (`{credit_limit_minor, version}`); a stale version is `CUSTOMER_VERSION_CONFLICT`, never an overwrite.
8. Reading customers and their balances needs `sale.create`, `report.view` or `debt.write_off` in the active branch.

## Error codes

| Code | When |
|---|---|
| `SALE_OVER_CREDIT_LIMIT` | credit sale would exceed customer limit — context `limit, balance, attempted` |
| `DEBT_OVERPAYMENT` | payment exceeds outstanding balance (when disallowed) |
| `DEBT_CURRENCY_MISMATCH` | payment currency has no matching charges |
| `CUSTOMER_INACTIVE` | charging/crediting an inactive customer |
| `CUSTOMER_CREDIT_LIMIT_INVALID` | a negative credit limit |
| `DEBT_PAYMENT_INVALID` | a debt payment of zero or less (a correction is an adjustment, not a negative payment) |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| balance derives | charge 500, payment 200 | read balance | `300` owed |
| within limit | limit=1000, balance=300 | credit sale +400 | allowed, balance 700 |
| over limit | limit=1000, balance=900 | credit sale +400 | `SALE_OVER_CREDIT_LIMIT` |
| overpayment rejected | balance=300 | pay 500 | `DEBT_OVERPAYMENT` |
| multi-currency | owes 300 AFN | pay 10 USD | `DEBT_CURRENCY_MISMATCH` |
| write-off audited | balance=300 | write off (perm ok) | balance 0, `debt.written_off` audited |
| cashier grants credit | cashier | create customer with limit 50000 (or none) | `ACCESS_DENIED`; limit 0 is allowed |
| manager raises a limit | manager, customer at version 1 | set limit 500000 with version 1 | allowed, version 2; again with version 1 → `CUSTOMER_VERSION_CONFLICT` |
| cashier raises a limit | cashier | set limit 500000 | `ACCESS_DENIED` |

## Audit

`debt.charge_posted` (via sale), `debt.payment_recorded`, `debt.written_off`, `customer.credit_limit_changed` — all audited (money).

## Sync class

- Customer: **mutable master data** (version + conflict).
- CustomerLedgerEntry / DebtPayment: **append-only ledger** — balances re-derive; concurrent offline payments both apply.
