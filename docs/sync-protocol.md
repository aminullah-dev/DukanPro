# Sync protocol (offline-first)

Status: **implemented** (Phase 6); push and pull **hardened** after the readiness review (theme 1). What a push may write is decided in one place, `server/dukan/application/sync_policy.py`; this document describes it.

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
| `actor_id` | user id; `system` for automatic device writes no user performed (the unit seed) |
| `created_at` | UTC |
| `status` | `pending` / `sent` / `acked` / `conflict` / `rejected` |

## Push

`POST /sync/push` with a bearer token and an optional `X-Branch-Id` header (the active branch for shop-wide rows; defaults to the user's default branch).

```json
{"device_id": "≤ 128 chars",
 "ops": [{"op_id": "<uuid>", "table": "sales", "row_id": "<uuid>", "op": "insert",
          "data": {"number": "INV-20260912-0001", "…": "…"}, "base_version": null,
          "actor_id": "<uuid, omitted for system seeds>", "created_at": "2026-09-12T08:00:00.000Z"}]}
```

1. The client sends, in `local_seq` order, the pending ops the **signed-in user** recorded plus system seeds. Another user's ops wait on the device for that user's own sync. The client sends at most 200 ops per request; the server accepts up to 500.
2. The server handles each op in its own transaction, in request order:
   1. `op_id` must be a canonical lowercase UUID (otherwise `rejected` `SYNC_OP_INVALID`, not recorded).
   2. **Replay:** an op_id already recorded returns its stored outcome, code and `server_seq`; nothing applies twice.
   3. **Envelope:** `row_id` is a canonical UUID; the table is known; `op` is `insert` or `update` and supported for that table; updates carry `base_version`; `actor_id`, when sent, is the token's user; `created_at`, when sent, is tz-aware ISO-8601.
   4. **Fields:** `data` is checked against the table's allow-list (next section).
   5. **Authorization** of the authenticated user in the row's branch.
   6. **Parents and invariants.**
   7. **Write:** an insert, or a compare-and-set update.
   8. **change_log:** the row's post-image and its `branch_id`.
   9. **Audit:** one entry, origin `sync` (see [domain/read-models-sync-audit.md](domain/read-models-sync-audit.md)).
   10. **Record** the op_id with its outcome, code, `server_seq`, actor and device (see "Outcome caching").
3. The response is HTTP 200 with one result per op: `{op_id, outcome: applied|conflict|rejected, server_seq?, code?}`. One bad op never fails the batch.
4. A request-level failure fails the whole request; nothing is marked on the device, and it re-sends everything next time (replays make that safe): `401` (token), `422 REQUEST_INVALID` (malformed body, e.g. `device_id` over 128 chars), `500 SYNC_UNAVAILABLE` (the database failed mid-batch; ops before it stay applied and replay).
5. The client acks `applied` ops and marks `conflict` ops. A `rejected` op is marked rejected and counted on the sync card, unless the server did not record the rejection (see "Outcome caching"): then it stays pending and is re-sent.

## Push validation and authorization

**Fields.** Every key in `data` must be on the table's allow-list. Anything else is `SYNC_FIELD_NOT_ALLOWED`, including the server-owned `id`, `version`, `created_*`, `updated_*`, `deleted_at`, `occurred_at` and cost columns. Values are strict:
- integers are JSON integers within PostgreSQL INTEGER range (never booleans, floats or strings);
- ids are canonical lowercase UUIDs; currencies are ISO-4217 codes;
- strings fit their column, are not blank when required, and contain no NUL.

`occurred_at` is the server's apply time; the device's time is kept in the audit entry.

**Authorization.** The permission is checked for the authenticated user (never a user named in the payload) in the branch the row belongs to: `branch_id` for sales and stock movements, the parent sale's branch for its children, the active branch for shop-wide rows. That branch must be active (`BRANCH_INACTIVE`, not recorded: the op applies once the branch reopens).

| Table, op | Permission (branch) | Rules |
|---|---|---|
| products insert | product.manage (active) | the unit exists; `category_id` and `cost_*` must be null; the currency one the shop's branches trade in (`PRICE_CURRENCY_INVALID`), as on REST; a SKU another live product has is **flagged** (`sku_taken`), not refused |
| products update | product.manage (active), plus price.change when the price or currency changes, plus purchase.cost for a cost | `base_version` required; only `name`, `sell_price_minor`, `sell_currency`, `is_active`, `track_stock`, `cost_minor` (a goods receipt's cost, in the selling currency); the currency one the shop's branches trade in (`PRICE_CURRENCY_INVALID`), as on REST |
| barcodes insert | product.manage (active) | the product exists; a code a live barcode has is refused (`BARCODE_DUPLICATE`) |
| barcodes update | product.manage (active) | `base_version` required; only `{deleted: true}`: the barcode is taken off its product (soft-deleted; its image carries `deleted_at`) |
| units insert | any role in the active branch for the device seed (piece/0, kg/3, litre/3, dozen/0, meter/2); product.manage otherwise | |
| customers insert | sale.create (active) | a credit limit other than 0 (null is unlimited) without customer.credit is stored as 0, and the audit keeps the requested limit |
| customers update | sale.create (active), plus customer.credit when the credit limit or `is_active` changes | `base_version` required; only `name`, `phone`, `credit_limit_minor`, `is_active` |
| suppliers insert | product.manage (active) | |
| stock_movements insert, `adjustment` | stock.adjust (row) | qty ≠ 0; the product tracks stock |
| stock_movements insert, `purchase` | stock.adjust (row) | qty > 0; the product tracks stock (`PRODUCT_NOT_STOCK_TRACKED`) |
| stock_movements insert, `sale` | sale.create (row) | the product tracks stock (`PRODUCT_NOT_STOCK_TRACKED`); qty < 0; `ref_type` `sale` and `ref_id` of the pusher's own sale in the same branch; never more out than that sale's lines hold for the product; a movement beyond the lines that have arrived, while some are still missing, is a retry (`SALE_LINES_NOT_FOUND`) |
| sales insert | sale.create (row), plus sale.discount for a discount above 0 | 0 ≤ discount ≤ subtotal; total = subtotal − discount + tax; paid ≥ total unless on credit, and never above the total (`SALE_OVERPAID`); the customer exists; a `shift_id` names the pusher's own shift in the branch (not arrived yet: `SHIFT_NOT_FOUND`, a retry; closed: **flagged** `after_shift_close`) |
| shifts insert | sale.create (row) | the pusher's own shift (`user_id`); a float of 0 or more; opened at the device's time |
| shifts update | sale.create for the shift's own seller, else report.view | `base_version` required; only an open shift closes (`SHIFT_ALREADY_CLOSED`); `status` closed and `counted_cash_minor`; the server sets the expected cash and the variance from its own rows |
| sale_lines insert | sale.create (sale's) | the pusher's own sale; line total = price × qty (half-up) at the decimal places of the product's unit (a pushed `decimal_places` that differs is refused, `SYNC_FIELD_INVALID`; a missing one is filled in); lines ≤ subtotal; the sale's currency; a pushed `unit_cost_minor` is ignored and set by the server from the product's cost; a unit price under the catalog price needs sale.discount or price.change, unless the product had that price within the 45 days before the sale (the time its header recorded) (a till that had not pulled a price change yet) |
| payments insert | sale.create (sale's) | the pusher's own sale, whose lines add up to its subtotal; payments ≤ paid and ≤ total; cash or card, a positive amount, and tendered (cash only) ≥ amount (`SALE_PAYMENT_INVALID`); cash, card or transfer |
| customer_ledger insert, `charge` | sale.create (sale's) | `ref_type` `sale` and `ref_id` of the pusher's own sale for that customer, whose lines add up to its subtotal; charges ≤ total − paid; over the credit limit is **flagged** in the audit, not refused; the customer's currency (`DEBT_CURRENCY_MISMATCH`); a customer whose account is closed is **flagged** (`customer_inactive`), not refused |
| customer_ledger insert, `payment` | sale.create (active) | no `ref_id`; the customer's currency; an overpayment is **flagged** in the audit, not refused; `method` (cash, card, transfer) and a `shift_id` naming the pusher's own shift in the branch |
| customer_ledger insert, `adjustment` | debt.write_off (active) | a write-off: a negative amount, `ref_type` `write_off`, no `ref_id`; the customer's currency; one past the balance is **flagged** (`exceeds_balance`), not refused |
| supplier_ledger insert, `bill` | purchase.cost (active) | the supplier exists; the supplier's currency |
| supplier_ledger insert, `payment` | purchase.cost (active) | the supplier exists; the supplier's currency; `method` (cash, card, transfer) and a `shift_id` naming the pusher's own shift in the branch; one past the balance is **flagged** (`overpaid`), not refused |

Everything else is `SYNC_OP_UNSUPPORTED` until an app flow needs it: categories, updates of anything but products and customers, stock transfers, counts and returns, customer opening balances and adjustments, supplier payments. Offline ledger entries that break a limit online would enforce still apply, because two tills can both act while offline; the audit flag is what the owner reviews.

## Push codes

`conflict`: `<TABLE>_VERSION_CONFLICT` (stale `base_version`), `<TABLE>_ALREADY_EXISTS` (insert on an existing master row).

`rejected`:
- Envelope: `SYNC_OP_INVALID`, `UNKNOWN_TABLE`, `SYNC_OP_UNSUPPORTED`, `SYNC_BASE_VERSION_REQUIRED`, `SYNC_ACTOR_MISMATCH`, `SYNC_OP_ID_TAKEN` (another user's applied op already holds this op_id).
- Fields: `SYNC_FIELD_NOT_ALLOWED`, `SYNC_FIELD_REQUIRED`, `SYNC_FIELD_INVALID`, `MONEY_CURRENCY_INVALID` (the context names the field and the reason).
- Access: `ACCESS_DENIED`, `BRANCH_REQUIRED`, `BRANCH_INACTIVE`.
- References: `PRODUCT_NOT_FOUND`, `UNIT_NOT_FOUND`, `CUSTOMER_NOT_FOUND`, `SUPPLIER_NOT_FOUND`, `SALE_NOT_FOUND`, `SALE_LINES_NOT_FOUND` (money or a stock movement against a sale whose lines have not all arrived), `SYNC_REF_MISMATCH`, `SYNC_ROW_EXISTS` (a ledger row id reused).
- Domain: `STOCK_INVALID_QTY`, `PRODUCT_NOT_STOCK_TRACKED`, `SALE_UNDERPAID`, `SALE_DISCOUNT_INVALID`, `SALE_CURRENCY_MISMATCH`, `DEBT_CURRENCY_MISMATCH`, `PURCHASE_CURRENCY_MISMATCH`.
- `ROW_INVALID`: an unexpected server error on that op.

## Outcome caching

A recorded outcome, with the version an applied master op produced (`processed_ops.version`, migration 0015), is returned on every replay of its op_id. Outcomes that depend on server state that can change are **not** recorded, so a replay re-evaluates them: `ACCESS_DENIED`, `SYNC_ACTOR_MISMATCH`, `BRANCH_REQUIRED`, `BRANCH_INACTIVE`, `ROW_INVALID` and every `*_NOT_FOUND`. Nothing was applied, so exactly-once still holds.

The client mirrors this: such an op stays pending and is re-sent on the next sync, for example when a parent still queued by another user arrives, a role is granted, or the right user signs in. An op on the same row as one refused for good takes that verdict (see "Master data concurrency"). An op whose parent row was rejected for good keeps coming back as `*_NOT_FOUND` and stays pending.

A recorded outcome belongs to the user who pushed it. When another user pushes the same op_id, a recorded failure (nothing was written) is discarded and the op is decided afresh; an op_id already applied for someone else is `SYNC_OP_ID_TAKEN`.

## Master data concurrency

An update is a compare-and-set: `UPDATE … WHERE id = :row_id AND version = :base_version AND deleted_at IS NULL`, then `version + 1`. Zero rows updated is a `conflict`, so two concurrent pushes can never both win. REST edits bump the version too (`PATCH /products/{id}` takes an optional `version` and answers `PRODUCT_VERSION_CONFLICT` when it is stale).

- A device bumps its local version with each edit and sends the version before the edit as `base_version`, so offline edits to one row chain.
- Some failures break the device's chain for a row. When one does, every later op on that row takes the same verdict: the server applies this within one push, the device across pushes. The later op was made on top of the failed one, and applied alone it would overwrite the server's row without review (for example, a price set after a conflicted rename). Two failures break the chain:
  - An edit that loses its compare-and-set (`*_VERSION_CONFLICT`). The device's local versions now collide with the server's, so a later edit's `base_version` can match by accident.
  - An insert refused for good. The row never existed.

  Other refusals leave the server's version where it was, so the device's next edit conflicts on its own.
- An applied master op returns the row's new `version`. A conflict returns `current`, the server's row as the pusher may read it (replays too).
- On a conflict the server's state wins. The device replaces its local copy with `current` and keeps the edit in a review list (Sync issues).
  - There the user can apply it again: the edit is written locally and queued against the server's version.
  - Or set it aside: it stays in the outbox for support, off the counts.
- A pulled master post-image older than the local row is skipped, so edits not yet pushed are never rewound.
- Barcodes:
  - An insert the server refuses (`BARCODE_DUPLICATE`, because another till gave the code first) is soft-deleted on the device, so the code the server kept wins its scans.
  - Removing a barcode another till already removed is applied as done, with nothing written.
  - Barcode images carry `created_at`.

## Attribution

The server applies an op only under the token of the user who recorded it: when `actor_id` is sent it must equal the token's user (`SYNC_ACTOR_MISMATCH` otherwise). Rows are stamped `created_by`/`updated_by` with that user.

`created_at` (the device's outbox time) and `device_id` are informational. They go to the audit entry and `processed_ops`, never into authorization. The app does not yet have a stable per-installation device id.

## Pull

`GET /sync/pull?since=<watermark>&since_token=<token>&limit=<1..1000, default 500>` returns `{changes: [{seq, table, row_id, op, data}], watermark, watermark_token, max_seq, scope, reset}`.
- `since < 0` or a limit out of range is `422 REQUEST_INVALID`.
- A user with no active role gets `403 ACCESS_DENIED`.

Each change is the row's **post-image**: its allow-listed business columns, plus `version` on master rows. It is filtered to what the pulling user may read:

| Table | Readable with | Where |
|---|---|---|
| products, barcodes, units, categories | any permission | shop-wide |
| customers, customer_ledger | sale.create, report.view or debt.write_off | shop-wide |
| suppliers | stock.adjust, product.manage or report.view | shop-wide |
| supplier_ledger | report.view or debt.write_off | shop-wide |
| stock_movements | any permission | branches where the user holds a role |
| sales, sale_lines, payments, shifts | sale.create or report.view | branches where the user holds a role with one of them |

Cost fields (`products.cost_minor`, `products.cost_currency`, `sale_lines.unit_cost_minor`) are **omitted** unless the user has product.manage or report.view. They are omitted, not nulled, because the client writes only the keys that are present. One user's pull therefore never wipes a value another user of the same device can see.

The watermark is the last row scanned, visible or not, so paging is monotonic. `watermark_token` names the change at the watermark, and the device sends it back as `since_token`.

Two answers make the device read the feed again from the start:
- `reset: true`: the server no longer holds that change. It was restored from a backup, even one whose feed has since grown back past the cursor.
- A different `scope`: the device's cursor was read in another scope. `scope` names what the user may read (their roles by branch), so a new value means a role or a branch was granted since. Reading again brings the rows the old scope hid, such as costs or another branch's history.

 Because the scope is per user, the client keeps **one cursor per user** on the device and pages until the watermark stops advancing. A user's first cursor starts from the device-wide cursor that earlier, unscoped pulls left behind.

Two rules keep one user's pull from undoing another's work on a shared device:
- A product post-image older than the local row is skipped. The local row is newer when it carries edits not yet pushed.
- A branch row whose branch cannot be told is visible to nobody. Migration 0008 back-fills the branch of feed rows logged before `change_log.branch_id` existed.

## Change feed and device time

- **One feed for every write.** Every write to a synced table, through sync or REST (products, barcodes, stock, customers, debt payments, suppliers, receipts, sales, voids), appends the row's post-image to `change_log` in the same transaction.
  - On PostgreSQL a transaction-scoped advisory lock taken before the append and held until commit makes `seq` follow commit order, so a pull never passes a row that commits later.
  - A writing transaction takes its row locks before its first append (a goods receipt locks its products first). The feed lock therefore always comes last, and a receipt cannot deadlock against a sync edit of the same product.
- **Restores.** A device reads the feed again from the start (applying is idempotent) in two cases: its cursor is past `max_seq`, or the server answers `reset` because the change named by the cursor's token is gone or has been replaced by another.
- **Device time.** Append-only rows (sales, stock movements, customer and supplier ledger entries) take the op's `created_at`, the moment the device recorded it, when it lies between 45 days before and 5 minutes after the server's clock. Otherwise they take the server's time. A till offline from Monday to Wednesday keeps Monday's sales on Monday. `occurred_at` itself is still never accepted in `data`.
- **Unreadable changes.** A pulled change the device cannot read is set aside (app setting `sync.quarantine`, the last 50) and the cursor still advances, so one bad row never stops every device's pull.
- **Receipt costs** travel as a `products` update of `cost_minor` against the version the device read.
- **Device identity.** Each install makes a UUIDv7 once and keeps it. It is sent at sign-in and push.
  - Sale numbers are `INV-<last 6 of the device id>-<local date>-<n>`, counted inside the settle transaction.
  - The server keeps a sale whose number another sale in the branch already has, and flags it in the audit entry (`number_taken`).
- **When it syncs.** The app syncs a few seconds after a local write and every two minutes while someone is signed in. Its counts follow the outbox live.

## Known limitations

- No tombstones yet: soft deletes do not reach devices.
- No document atomicity: a sale's rows apply one op at a time. A header counts in reports as soon as it arrives, even while its lines are still queued; money against it (payments, charges) waits for the lines. Grouping a device transaction into one all-or-nothing push is still to do.
- A rejected append-only op (a sale line, a payment) is not undone on the device: it is listed for review, and its local effect stays until someone acts on it.
- Line prices are the device's price at sale time. The server does not reprice them; the audit entry records the catalog price next to it, and flags a line under it (`below_catalog`). A line under every price the product had in the 45 days before the sale needs sale.discount or price.change (`ACCESS_DENIED`, retried: granting the role lets it apply). The price history comes from the audit trail's `product.price_changed` entries.
- Business numbers are not leased yet (decision B below); device-prefixed numbers keep devices from colliding.

## Rollout of the hardened push

1. Upgrade the server and the apps together.
   - An old app records sale stock movements without a `ref_id`.
   - On upgrade, the new app's local schema v7 links its still-pending movements to their sale, so these devices need not be drained first.
   - A movement an old app pushes to the new server is rejected (`SYNC_FIELD_REQUIRED`) for good, so a device that stays on the old app should sync before the server is upgraded.
2. Migration `0008` is additive (nullable columns) and reversible.
3. After the upgrade, watch the rejected count on devices, and audit entries flagged `over_credit_limit` or `overpaid`.

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
- Where they live:
  - Server: `server/tests/unit/test_sync_policy.py`, `server/tests/integration/test_sync.py`, `server/tests/integration/test_sync_hardening.py`.
  - Client: `packages/dukan_data/test/sync_engine_test.dart` (a fake server that mirrors these rules), `app/test/sync_controller_test.dart`, `app/test/sync_api_test.dart`.
