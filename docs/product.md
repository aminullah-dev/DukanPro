# DukanPro — product definition

## Vision

A fast, offline-first point-of-sale and shop-management app that an Afghan retailer can run on the device they already have — a phone, a tablet, or a Mac at the counter — in Dari, Pashto, or English. It sells, tracks stock, manages customer credit (nasia/قرض), records purchases from suppliers, and tells the owner what is happening in their shop, with or without an internet connection.

## Target users (personas)

| Persona | Role | Primary device | Needs |
|---|---|---|---|
| **Dukandar** (owner) | admin | phone + counter Mac/tablet | see sales/profit, set prices, manage debt, trust the numbers |
| **Cashier / clerk** | operator | tablet / phone / counter | ring up sales fast, scan barcodes, print receipts, take partial/credit payments |
| **Stock keeper** | operator | phone | receive goods, count stock, transfer between branches |
| **Accountant / manager** (Pro+) | manager | Mac / tablet | reports, debtor aging, supplier balances, multi-branch view |

## Scope

**In scope (across the 10 phases):** products & inventory; POS & sales; customers, debt/credit ledgers; suppliers & purchases; reports & dashboard; offline sync; employees, roles & multi-branch; hardware (scanners, thermal printers, cash drawer); AI insights & notifications; audit, performance, security.

**Non-goals (Phase 0):** public e-commerce storefront; payroll; full double-entry general ledger / formal accounting suite; manufacturing/BOM; third-party marketplace integrations. These may be revisited post-1.0.

## Editions & feature flags

**One binary; editions are runtime flags** read from the license (never separate builds or branches — per `platform-core`). Flags are dotted, lowercase.

| Edition | Includes | Representative flags |
|---|---|---|
| **Base** | single branch, POS, products/inventory, customers + debt, basic receipts & reports | *(base set, no flags needed)* |
| **Pro** | multi-branch, purchasing, advanced reports, roles | `sales.multi_branch`, `inventory.multi_warehouse`, `purchasing.enabled`, `reports.advanced`, `iam.roles` |
| **Enterprise** | server sync, AI, push, audit export, hardware fleet | `sync.server`, `ai.insights`, `notifications.push`, `audit.export`, `hardware.fleet` |

A feature gated by a flag checks it at the **application layer** (use case), not in the UI, so every surface enforces it identically. Demo/unlicensed state watermarks printed documents (see `licensing`).

**Base is a whole shop on one device.** Setup offers "without a server" beside first-run setup; the device then keeps its own owner account and its own books and never calls anywhere — nothing to install, no internet, nothing to reach. What a server would own (staff, branches, the audit trail, insights, sync) is not offered there. See [`docs/domain/identity-access.md`](domain/identity-access.md).

## Success criteria for Phase 0

1. The architecture is decided, recorded (ADR-0001), and its domain-isolation contract is machine-enforced on both client and server.
2. The domain is specified aggregate-by-aggregate ([`docs/domain/`](domain/)) as the shared source of truth for Dart and Python.
3. A cashier can **walk the core sale flow** in the POS mockup in all three locales, including RTL, with correct Pashto glyph rendering.
4. The monorepo skeleton builds, the pure-Dart core tests pass with zero fixtures, and the server serves `/health`.

## Guiding product principles

- **Offline is the default, not a fallback.** A sale must never wait for a network.
- **The numbers must be trustworthy.** Money and stock are append-only ledgers; nothing is silently overwritten; everything that matters is audited.
- **Local-first language & culture.** Dari and Pashto are first-class, RTL is not an afterthought, Hijri Shamsi dates and AFN are native.
- **Fast on the hardware people own.** The counter is often a mid-range phone or tablet; the POS screen must stay responsive there.
