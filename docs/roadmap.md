# DukanPro — roadmap → architecture mapping

Each phase has a known home in the architecture, so work never refactors the skeleton. Layers: **core** (`dukan_core`, pure Dart + `server/domain`+`application`), **data** (`dukan_data`/Drift + `server/infrastructure`+Postgres), **sync** (`dukan_sync` + server sync endpoints), **ui** (`app/`), **hw** (`dukan_hardware`).

| Phase | Theme | Primary aggregates / modules | Layers touched | Edition / flags |
|---|---|---|---|---|
| **0** | Architecture + Product + UX | — (specs + skeleton) | all (scaffold) | — |
| **1** | Foundation + Auth + Database | Identity & Access (User, Session) | core, data, ui | Base |
| **2** | Products + Inventory | Catalog, Inventory (StockItem, StockMovement) | core, data, ui, hw (scan) | Base; `inventory.multi_warehouse` (Pro) |
| **3** | POS + Sales | Sales (Sale, SaleLine, Payment, Receipt, Shift) | core, data, ui, hw (print, drawer) | Base |
| **4** | Customers + Debt + Purchases | Customers & Debt, Purchasing (Supplier, PO, GoodsReceipt) | core, data, ui | Base (debt); `purchasing.enabled` (Pro) |
| **5** | Reports + Dashboard | read models (sales, stock valuation, debtor aging, profit) | core (queries), data, ui | Base (basic); `reports.advanced` (Pro) |
| **6** | Offline Sync | `dukan_sync`, outbox, server sync endpoints, leased numbers | sync, data, core, server | `sync.server` (Enterprise) |
| **7** | Employees + Branches + Security | Identity & Access (Role, Permission), Branches | core, data, ui, server | `iam.roles`, `sales.multi_branch` (Pro) |
| **8** | Mac + iPad + Hardware | adaptive UI, platform channels, device certification | ui, hw, platform runners | `hardware.fleet` (Enterprise) |
| **9** | AI + Notifications | AI insight services (server), push | server, ui | `ai.insights`, `notifications.push` (Enterprise) |
| **10** | Audit + Performance + Security | audit export, perf passes, hardening, pen-test fixes | all | `audit.export` (Enterprise) |

## Notes

- **Sync-readiness from Phase 1.** Even before the sync engine exists (Phase 6), every write goes through the outbox pattern, so no Phase 1–5 code needs rewriting to become syncable.
- **Hardware behind interfaces from Phase 2.** `dukan_hardware` exposes scanner/printer/drawer *ports* early; real drivers land in Phase 8 (with enough in Phase 2–3 to demo scan + print).
- **Every money/stock/permission-touching change is audited** from the phase it is introduced — not retrofitted in Phase 10.
- **Editions are additive flags**, so a phase can ship Base behaviour and gate the Pro/Enterprise extension behind a flag in the same PR.
