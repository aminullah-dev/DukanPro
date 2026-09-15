# Branches & Warehouses

**Purpose:** scope stock, sales, and staff to a physical location. (Phase 7; single-branch is the Base default.)

## Entities & value objects

- **Branch** — `{ id, name, address?, timezone, currency_default, is_active }`. The Base edition always has exactly one (the shop itself).
- **Warehouse** (optional, `inventory.multi_warehouse`) — `{ id, branch_id, name }`. Stock can be tracked per warehouse within a branch; by default a branch has one implicit warehouse.

## Invariants

1. **Stock, sales, shifts, and POs are always scoped to a branch.** A StockMovement without a `branch_id` is invalid.
2. Multi-branch features are gated by `sales.multi_branch`; in Base, the single branch is implicit and not shown as a chooser.
3. A Transfer moves stock **between branches** (see `inventory.md`) and is the only way stock crosses a branch boundary.
4. A branch's `timezone` defines its **business day** for reporting: from its local midnight to the next, as a UTC range (`business_day` / `businessDay`, the same on the server and the device). Times people read are on this clock too.
   - The zone is one of a fixed table with no daylight saving time: Asia/Kabul (the default), Asia/Karachi, Asia/Tashkent, Asia/Dushanbe, Asia/Dubai, Asia/Tehran, UTC. So the device needs no time zone database. A zone with daylight saving time would need one on the device.
   - The currency is AFN, the only one for now (decided 2026-09-14). The signed-in profile carries each branch's zone and currency.
5. Deactivating a branch blocks every new write there (sales, shifts, receipts, stock, staff; sync ops wait and retry) with `BRANCH_INACTIVE`, and preserves history: reads still work.
6. Opening a branch is a shop-wide act: `branch.manage` in every branch. The shop's owners become owners of the new branch in the same transaction, so it can be administered.

## Error codes

| Code | When |
|---|---|
| `BRANCH_REQUIRED` | a branch-scoped operation with no active branch |
| `BRANCH_INACTIVE` | operating on a deactivated branch |
| `BRANCH_LAST_ACTIVE` | deactivating the only active branch |
| `BRANCH_TIMEZONE_INVALID` | opening a branch in a zone not in the table |
| `BRANCH_CURRENCY_INVALID` | opening a branch with a currency the shop does not support |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| movement needs branch | movement, branch_id=null | post | `BRANCH_REQUIRED` |
| single-branch implicit | Base edition | open POS | no branch chooser; uses the one branch |
| business day local | branch tz=Asia/Kabul | daily report for "today" | Kabul-local range, not UTC |
| day boundary | Kabul, 01:00 on 12 Sep (20:30 UTC on the 11th) | today's range | 19:30 UTC on the 11th to 19:30 UTC on the 12th |
| zone checked | open a branch with tz=Mars/Olympus | create | `BRANCH_TIMEZONE_INVALID` |
| last branch protected | one active branch | deactivate it | `BRANCH_LAST_ACTIVE` |
| inactive branch | branch B2 deactivated | sell or hire in B2 | `BRANCH_INACTIVE` |
| new branch owned | owner opens B2 | read B2's dashboard | allowed |

## Audit

`branch.created` (with `role.assigned` for its owners), `branch.deactivated`, `warehouse.created` — audited (structure/identity).

## Sync class

Branch / Warehouse: **mutable master data** (version + conflict), low write frequency.
