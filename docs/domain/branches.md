# Branches & Warehouses

**Purpose:** scope stock, sales, and staff to a physical location. (Phase 7; single-branch is the Base default.)

## Entities & value objects

- **Branch** — `{ id, name, address?, timezone, currency_default, is_active }`. The Base edition always has exactly one (the shop itself).
- **Warehouse** (optional, `inventory.multi_warehouse`) — `{ id, branch_id, name }`. Stock can be tracked per warehouse within a branch; by default a branch has one implicit warehouse.

## Invariants

1. **Stock, sales, shifts, and POs are always scoped to a branch.** A StockMovement without a `branch_id` is invalid.
2. Multi-branch features are gated by `sales.multi_branch`; in Base, the single branch is implicit and not shown as a chooser.
3. A Transfer moves stock **between branches** (see `inventory.md`) and is the only way stock crosses a branch boundary.
4. A branch's `timezone` defines its **business day** for reporting (a "day" is a branch-local range, not UTC `date()`).
5. Deactivating a branch blocks every new write there (sales, shifts, receipts, stock, staff; sync ops wait and retry) with `BRANCH_INACTIVE`, and preserves history: reads still work.
6. Opening a branch is a shop-wide act: `branch.manage` in every branch. The shop's owners become owners of the new branch in the same transaction, so it can be administered.

## Error codes

| Code | When |
|---|---|
| `BRANCH_REQUIRED` | a branch-scoped operation with no active branch |
| `BRANCH_INACTIVE` | operating on a deactivated branch |
| `BRANCH_LAST_ACTIVE` | deactivating the only active branch |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| movement needs branch | movement, branch_id=null | post | `BRANCH_REQUIRED` |
| single-branch implicit | Base edition | open POS | no branch chooser; uses the one branch |
| business day local | branch tz=Asia/Kabul | daily report for "today" | Kabul-local range, not UTC |
| last branch protected | one active branch | deactivate it | `BRANCH_LAST_ACTIVE` |
| inactive branch | branch B2 deactivated | sell or hire in B2 | `BRANCH_INACTIVE` |
| new branch owned | owner opens B2 | read B2's dashboard | allowed |

## Audit

`branch.created` (with `role.assigned` for its owners), `branch.deactivated`, `warehouse.created` — audited (structure/identity).

## Sync class

Branch / Warehouse: **mutable master data** (version + conflict), low write frequency.
