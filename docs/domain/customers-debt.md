# Customers & Debt

**Purpose:** track customers and the credit (nasia / قرض) they owe. (Phase 4.)

## Entities & value objects

- **Customer** — `{ id, name, phone?, branch_id?, credit_limit(Money|none), is_active }`.
- **CustomerLedgerEntry** (append-only) — `{ id, customer_id, entry_type(charge|payment|adjustment|opening), amount(Money, signed by convention), ref_type(sale|manual|write_off|void), ref_id, occurred_at, note? }`.
- **Balance** (derived) — `balance = Σ charges − Σ payments` over the ledger. Positive = customer owes the shop.
- **DebtPayment** — `{ id, customer_id, amount(Money), method, allocated_to:[sale_id]?, occurred_at }`. Emits a `payment` ledger entry.

## Invariants

1. **Balance is derived** from the append-only ledger — never a stored mutable total.
2. A credit sale posts a `charge` entry for the unpaid remainder (in the sale's currency). The ledger is **per currency**; a customer may owe AFN and USD separately (no implicit conversion).
3. A credit sale is rejected if it would push the customer's balance above `credit_limit` (when a limit is set) → `SALE_OVER_CREDIT_LIMIT` (raised in Sales, enforced against this balance).
4. A DebtPayment cannot exceed the outstanding balance in that currency → `DEBT_OVERPAYMENT` (unless an explicit over-payment/credit-balance is allowed by config; default: reject).
5. **A write-off** forgives part or all of the balance: a negative `adjustment` (`ref_type` `write_off`) of at most the balance, needing `debt.write_off`, audited `debt.written_off`. The customers screen records it offline and syncs it; `POST /customers/{id}/write-offs` (`{amount_minor}`) does it online. A synced write-off that outruns the balance (another till took a payment meanwhile) is flagged in the audit, not refused, like an overpayment.
6. Ledger entries are append-only and immutable; corrections are compensating entries.
7. **Credit is a manager's decision.** Setting any credit limit other than 0 (none means unlimited) needs `customer.credit` (owner, manager); a limit is never negative (`CUSTOMER_CREDIT_LIMIT_INVALID`). A customer a cashier creates offline syncs with limit 0, and its audit entry keeps the requested limit. A manager changes the limit later from the customers screen (a sync `customers` update) or with `PUT /customers/{id}/credit-limit` (`{credit_limit_minor, version}`); a stale version is `CUSTOMER_VERSION_CONFLICT`, never an overwrite.
8. Reading customers and their balances needs `sale.create`, `report.view` or `debt.write_off` in the active branch.
9. **Voiding a credit sale takes its debt back:** one negative `adjustment` (`ref_type` `void`, `ref_id` the sale) per charge the sale made.
10. **Credit goes only to an open account, in the customer's currency** (`CUSTOMER_INACTIVE`, `DEBT_CURRENCY_MISMATCH`), checked against the customer's own row on the device and the server (not the screen's copy). Closing or reopening an account is a manager's decision (`customer.credit`): the customers screen (a sync `customers` update) or `PUT /customers/{id}/status` (`{is_active, version}`). A credit sale a till made before it heard of the closing is kept (the goods left the shop) and flagged in the audit (`customer_inactive`). A closed account can still pay.

## Error codes

| Code | When |
|---|---|
| `SALE_OVER_CREDIT_LIMIT` | credit sale would exceed customer limit — context `limit, balance, attempted` |
| `DEBT_OVERPAYMENT` | payment exceeds outstanding balance (when disallowed) |
| `DEBT_CURRENCY_MISMATCH` | a payment, write-off or credit sale in a currency other than the customer's |
| `CUSTOMER_INACTIVE` | charging/crediting an inactive customer |
| `CUSTOMER_CREDIT_LIMIT_INVALID` | a negative credit limit |
| `DEBT_PAYMENT_INVALID` | a debt payment of zero or less (a correction is an adjustment, not a negative payment) |
| `DEBT_WRITE_OFF_INVALID` / `DEBT_WRITE_OFF_EXCEEDS_BALANCE` | a write-off of zero or less / of more than the balance |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| balance derives | charge 500, payment 200 | read balance | `300` owed |
| within limit | limit=1000, balance=300 | credit sale +400 | allowed, balance 700 |
| over limit | limit=1000, balance=900 | credit sale +400 | `SALE_OVER_CREDIT_LIMIT` |
| overpayment rejected | balance=300 | pay 500 | `DEBT_OVERPAYMENT` |
| multi-currency | owes 300 AFN | pay 10 USD | `DEBT_CURRENCY_MISMATCH` |
| write-off audited | balance=300 | write off (perm ok) | balance 0, `debt.written_off` audited |
| write-off too large | balance=300 | write off 500 | `DEBT_WRITE_OFF_EXCEEDS_BALANCE` |
| void takes debt back | credit sale charged 500 | void the sale | balance back by 500 (`adjustment` −500, `void`) |
| closed account | account closed | credit sale | `CUSTOMER_INACTIVE`; a sale paid in full is fine |
| cashier grants credit | cashier | create customer with limit 50000 (or none) | `ACCESS_DENIED`; limit 0 is allowed |
| manager raises a limit | manager, customer at version 1 | set limit 500000 with version 1 | allowed, version 2; again with version 1 → `CUSTOMER_VERSION_CONFLICT` |
| cashier raises a limit | cashier | set limit 500000 | `ACCESS_DENIED` |

## Audit

`debt.charge_posted` (via sale), `debt.payment_recorded`, `debt.written_off`, `customer.credit_limit_changed`, `customer.deactivated` / `customer.reactivated`, and a void's `debt_reversed` in `sale.voided` — all audited (money).

## Sync class

- Customer: **mutable master data** (version + conflict).
- CustomerLedgerEntry / DebtPayment: **append-only ledger** — balances re-derive; concurrent offline payments both apply.
