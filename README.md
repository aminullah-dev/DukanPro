# DukanPro

Offline-first, cross-platform retail point-of-sale for the Afghan market
(Dari / Pashto / English · AFN · Hijri Shamsi). iPhone · iPad · Android
phone/tablet · macOS (Windows next).

> **Status: Phase 0 — architecture, product, UX, and skeleton.** See
> [`docs/architecture-decision.md`](docs/architecture-decision.md) for the
> stack decision and [`docs/`](docs/) for the full design.

## Stack

- **Client:** Flutter (Dart) — one codebase for all platforms. Riverpod + go_router.
- **Local store:** SQLite via Drift (wired Phase 1).
- **Sync:** offline-first operation queue + idempotent push/pull ([`docs/sync-protocol.md`](docs/sync-protocol.md)).
- **Backend:** Python 3.12 + FastAPI + SQLAlchemy + Alembic, **PostgreSQL**.

## Layout

```
packages/dukan_core/      pure Dart: domain + application ports + shared primitives (no framework)
packages/dukan_data/      SQLite/Drift repositories (Phase 0: in-memory)
packages/dukan_sync/      sync engine contracts (engine: Phase 6)
packages/dukan_hardware/  scanner / ESC-POS printer / cash-drawer ports
app/                      Flutter app (ios, android, macos, windows runners)
server/                   FastAPI backend (Clean Architecture, import-linter enforced)
docs/                     ADR, product, domain specs, UX + POS mockup, sync protocol
tools/                    l10n parity check, verify script
```

The **domain layer imports no framework** — enforced structurally: `dukan_core`
has no Flutter dependency, and the server's `dukan.domain` is guarded by
import-linter contracts.

## Develop

Prerequisites: Flutter (stable), Python 3.12.

```bash
# Dart packages
cd packages/dukan_core && dart pub get && dart test

# Flutter app (macOS shown)
cd app && flutter pub get && flutter gen-l10n && flutter run -d macos

# Server
cd server && python3.12 -m venv .venv && ./.venv/bin/pip install -e ".[dev]"
./.venv/bin/uvicorn dukan.ui.app:app --reload   # GET /health
```

Run every check at once:

```bash
bash tools/verify.sh
```

Melos (optional monorepo orchestration): `dart pub global activate melos` then
`melos run analyze` / `melos run test`.

## License

Proprietary — © DukanPro. Not for redistribution.
