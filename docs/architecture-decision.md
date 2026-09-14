# ADR-0001 — DukanPro platform architecture

- **Status:** Accepted
- **Date:** 2026-09-11
- **Deciders:** Product owner (Amin Hashemi) + Claude Code
- **Supersedes:** an earlier draft that placed DukanPro on the Enterprise Platform family stack (PySide6 desktop + Kotlin Android + FastAPI)

## Context

DukanPro is a **production-grade, cross-platform commercial retail POS platform** (dukan = shop) for the Afghan market — Dari, Pashto, and English; AFN currency; Hijri Shamsi calendar. It must:

- Run on **iPhone, iPad, Android phone, Android tablet, and macOS**, with **Windows** as a near-term follow-on.
- Be **offline-first**: a shop must sell, take payments, and manage stock with no network, then sync reliably.
- **Share as much production code as reasonably possible** across those platforms.
- Integrate retail hardware: **barcode scanners, thermal (ESC/POS) receipt printers, cash drawers**.
- Scale to **many businesses and many devices** per business.

The Enterprise Platform family (MediFlow, WorkTrack, Talar, the tailor ERP) standardises on Python/PySide6 for desktop and Kotlin for Android. That stack was rejected for DukanPro because it **fragments the UI across toolkits and provides no iOS/iPadOS application at all** — a hard requirement here.

## Decision

Adopt a **single cross-platform client in Flutter/Dart** backed by a **Python FastAPI server** with **PostgreSQL**, **SQLite (via Drift)** on the client, and a **custom offline-first sync engine** (local operation queue + idempotent push/pull).

```
Flutter/Dart app  ──(HTTPS/JSON, offline-first sync)──▶  FastAPI server ──▶ PostgreSQL
   │  SQLite (Drift) local store + outbox                     │  authoritative
   └─ iOS · iPadOS · Android phone · Android tablet · macOS · (Windows)
```

### Why Flutter over the alternatives

A first-principles comparison (Flutter A · Kotlin Multiplatform + Compose B · fully native C · React Native D) against 23 criteria is recorded in the Phase 0 plan. The decisive points:

- **Only single-codebase option that ships all five required UIs** (plus near-free Windows), AOT-compiled to native ARM — so a dense POS grid and rapid barcode entry stay smooth.
- **The riskiest subsystem — sync + domain rules + local persistence — is written once** in Dart. Fully-native duplicates this per platform, the largest source of silent money/stock bugs, and is therefore disqualified for a financial POS.
- **Best effort/quality ratio for a lean team:** one language to hire for, one test suite, fastest delivery. KMP is the honest runner-up and would win only if the team were Swift+Kotlin-centric or pixel-perfect native UI were a hard requirement — neither holds.
- **Mature local DB (Drift) and proven store/desktop distribution.**

### What we keep from `platform-core`

The family's *surface technology* is rejected, but its **four invariants and cross-cutting decisions are language-agnostic engineering rules** and are retained **on both client (Dart) and server (Python)**:

1. **Clean Architecture, dependencies point inward.** `domain` imports no framework. On the client this is enforced structurally: `dukan_core` is a **pure-Dart package with no Flutter dependency**. On the server, import-linter contracts enforce it.
2. **UUIDv7 string ids**, generated in the application layer, never by the database. User-facing **business numbers** (`INV-2026-00417`) are separate and server-assigned.
3. **Money is integer minor units + ISO-4217 code**; floats are banned in money paths; cross-currency arithmetic raises.
4. **Time is UTC/ISO-8601, tz-aware**, via an injected `Clock`; Hijri Shamsi is display-only.
5. **Every table** carries `id, created_at, updated_at, deleted_at, created_by, updated_by, version`; **soft delete** default; **optimistic concurrency** via `version` → `ConflictError`.
6. **One `AppError` base + stable `<AGGREGATE>_<CONDITION>` codes**; the code is the contract, the translation is not.
7. **Audit entries** (append-only, in-transaction) for anything touching money, stock, pricing, permissions, or deletion.
8. **Localization `en` / `fa-AF` / `ps`**, RTL via logical properties, Hijri display, bundled Perso-Arabic fonts; no user-visible literal in code.
9. **One binary per product; editions are runtime feature flags**, never branches.

The **FastAPI + PostgreSQL backend stays aligned** with the family's `api-service` and `data-layer` conventions.

## Consequences

- DukanPro **shares the family's conventions and backend patterns, but not compiled code.** It cannot reuse the family's PySide6/Compose UI or Kotlin domain. This is an accepted, deliberate deviation.
- **Domain rules are implemented in two languages** (Dart client = optimistic; Python server = authoritative). This is inherent to *any* offline-first app with a Python backend. Mitigation: the domain **specification** in [`docs/domain/`](domain/) is the single source of truth, with **identical test tables** mirrored in both languages — divergence becomes a failing test, not a production bug.
- The **server is authoritative; the client validates optimistically** — never the reverse.
- Hardware and per-OS concerns live behind owned interfaces (`dukan_hardware`) and platform channels; see [`docs/localization.md`](localization.md) and the Phase 0 plan's "platform-specific exceptions".

## Server data rules

- **Frozen migrations.** An Alembic revision is plain DDL and never reads the live models, so every model change comes with a new revision. The tests upgrade an empty database to head and compare it with the models, walk every revision with a row in every table, and downgrade to base and back. CI runs them on SQLite and on PostgreSQL.
- **64-bit money.** Money (minor units) and quantities are `BIGINT`, bounded at the API by `MONEY_MAX` (2^53 − 1, exact as a JSON number). Counters and versions stay 32-bit.
- **One error shape.** Every failure answers `{error: {code, context}}`: domain errors with their code, a malformed request `REQUEST_INVALID` (422), anything unexpected `INTERNAL` (500), with the traceback only in the server log.
- **One connection per request.** Authentication hands its database connection back before the endpoint runs. The PostgreSQL pool covers the request threads and replaces dropped connections.

## Validate early (tracked risks)

- **Pashto text shaping** in Flutter's text engine (`ټ ډ ړ ږ ښ ګ ڼ`) — prototype prose + a printed receipt on every target; bundle a vetted Naskh font; add golden tests.
- **Sync correctness for money/stock** — append-only ledgers (no blind last-write-wins on quantities); see [`docs/sync-protocol.md`](sync-protocol.md).
- **iOS background limits** — sync on foreground/resume + push-nudge.
- **Thermal-printer fragmentation** — standardise on ESC/POS over TCP :9100 first.

## Links

- Phase 0 plan (full 23-criterion comparison): `~/.claude/plans/phase-0-architecture-giggly-gizmo.md`
- Sync design: [`docs/sync-protocol.md`](sync-protocol.md)
- Product definition: [`docs/product.md`](product.md) · Roadmap: [`docs/roadmap.md`](roadmap.md)
- Domain specification: [`docs/domain/`](domain/)
