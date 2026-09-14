# Catalog

**Purpose:** what the shop sells and at what price. (Phase 2.)

## Entities & value objects

- **Product** — `{ id, sku, name_i18n, category_id, unit_id, is_active, track_stock(bool) }`. `name_i18n` holds per-locale names where relevant; the UI label key still applies for chrome.
- **ProductVariant** (optional) — `{ id, product_id, attributes(e.g. size/color), sku }`. A product with no variants sells directly; a variant-bearing product sells via its variants.
- **Barcode** — `{ id, product_or_variant_id, code, symbology }`. A product/variant may have several barcodes (case vs unit).
- **Category** — `{ id, name_i18n, parent_id? }` (tree).
- **Unit** — `{ id, name_i18n, decimal_places }` (e.g. piece=0 dp, kg=3 dp). Controls whether fractional quantities are allowed.
- **Price** (value object) — current selling price `Money`; optional **PriceList** entries per branch/customer-group (Pro).
- **Cost** — last/average purchase cost `Money`, maintained by Purchasing (see `purchasing.md`); catalog stores it but Purchasing owns it.

## Invariants

1. **`sku` is unique** among active products; **`barcode.code` is unique** among active barcodes (a scan must resolve to exactly one sellable item).
2. A Price/Cost is always a `Money` with a currency; a product's default selling currency is the shop currency unless a PriceList overrides it.
3. A unit's `decimal_places` governs quantity precision: selling 1.5 of a 0-dp unit (piece) is a `ValidationError`.
4. Deactivating a product (`is_active=false`) hides it from new sales but never deletes history (soft delete / flag).
5. Selling price below cost is **allowed but flagged** (owner may sell at loss); it raises no error, but the sale records the margin for reporting.

## Built-in units

`piece` (0 decimal places), `kg` (3), `litre` (3), `dozen` (0) and `meter` (2) have fixed ids, the same on the server and on every device (`builtInUnits` / `BUILTIN_UNITS`).
- The server seeds them at bootstrap and in migration 0011, and they are in the change feed like any unit (0012 logs them for databases made before). Reading units on the server never writes.
- A device adds any that are missing whenever it reads units, and never queues them for sync.
- Before the ids were fixed, every device seeded its own copies and pushed them. Server migration 0012 and device schema 9 merge each copy into its built-in unit: products move to it (a product edit in the feed), the copy is soft-deleted, and a device's queued ops for it follow.
- Custom units are ordinary synced rows.
- A quantity is always read in its product's unit. A screen that cannot find the unit says so (it never assumes 0 decimal places), and the server answers `UNIT_NOT_FOUND`.

## Error codes

| Code | When |
|---|---|
| `PRODUCT_DUPLICATE_SKU` | sku collides with an active product |
| `BARCODE_DUPLICATE` | barcode collides with an active barcode |
| `CATALOG_UNIT_PRECISION` | quantity has more decimals than the unit allows |
| `PRICE_CURRENCY_INVALID` | price currency is not the currency of any branch |
| `CATALOG_PRICE_INVALID` | a negative selling price |
| `CATEGORY_NOT_FOUND` | a product in a category that does not exist |
| `CATALOG_QTY_INVALID` | a typed quantity that is not a number |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| duplicate sku | active product sku="A1" | create sku="A1" | `PRODUCT_DUPLICATE_SKU` |
| duplicate barcode | barcode "500..." exists | add same barcode | `BARCODE_DUPLICATE` |
| fractional piece | unit=piece(0dp) | set qty 1.5 | `CATALOG_UNIT_PRECISION` |
| fractional kg ok | unit=kg(3dp) | set qty 1.250 | allowed |
| reactivated sku reuse | product sku="A1" soft-deleted | create sku="A1" | allowed (old is deleted) |

## Audit

`product.created`, `product.price_changed` (price touches money → audited), `product.deactivated`, `barcode.added`.

## Sync class

All catalog entities: **mutable master data** (version + conflict). Price changes are versioned; historical sale lines snapshot the price at sale time (see `sales.md`) so a later price edit never rewrites past revenue.
