# DukanPro

Offline-first, cross-platform retail point-of-sale for the Afghan market
(Dari / Pashto / English · AFN · Hijri Shamsi). iPhone · iPad · Android
phone/tablet · macOS (Windows next).

> **Status: all ten phases of [`docs/roadmap.md`](docs/roadmap.md) are built.**
> The till sells, voids and takes goods back without a server, syncs when there
> is one, and a whole shop can run on a single device. What is still missing
> before a real shop uses it is in [Not finished](#not-finished). See
> [`docs/architecture-decision.md`](docs/architecture-decision.md) for the
> stack decision and [`docs/`](docs/) for the full design.

## Stack

- **Client:** Flutter (Dart) — one codebase for all platforms. Riverpod + go_router.
- **Local store:** SQLite via Drift, encrypted with SQLCipher under a key only
  the device holds.
- **Sync:** offline-first operation queue + idempotent push/pull ([`docs/sync-protocol.md`](docs/sync-protocol.md)).
- **Backend:** Python 3.12 + FastAPI + SQLAlchemy + Alembic, **PostgreSQL**.
- **Two ways to run a shop:** with a server behind it (staff, branches, audit
  trail, several devices syncing), or **one device on its own** — no server to
  install and no internet at all. Chosen when the shop is first set up
  ([`docs/domain/identity-access.md`](docs/domain/identity-access.md)). A shop
  on one device backs itself up to a file encrypted with its password, and
  restores from it onto a new device.

## Layout

```
packages/dukan_core/      pure Dart: domain + application ports + shared primitives (no framework)
packages/dukan_data/      SQLite/Drift repositories, the outbox, the encrypted database
packages/dukan_sync/      the sync engine: push, pull, watermarks, conflicts
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
./.venv/bin/uvicorn dukan.composition:app --reload   # GET /health
```

Run every check at once:

```bash
bash tools/verify.sh
```

Melos (optional monorepo orchestration): `dart pub global activate melos` then
`melos run analyze` / `melos run test`.

## Not finished

Built does not mean shipped. What is still open:

- **Not on `main` yet.** The handover work waits in PR #5: the app icon, signed
  Android release builds, camera scanning, Bluetooth, BLE and USB printers,
  backups for a shop with no server, and receipts sent as PDF.
- **Deferred on purpose.** Push notifications (the app keeps its own in-app
  feed instead), and a real language model behind the insight narrator, which
  is template-based today.
- **Built, not yet tried on real hardware.** Camera scanning on a device without
  Google Play services, and Bluetooth, BLE and USB receipt printers
  ([`docs/hardware.md`](docs/hardware.md)).
- **Before a shop uses it.** A server and a domain for the multi-device setup;
  the Android upload key, which only the app's owner should create and keep
  ([`docs/release-android.md`](docs/release-android.md)); TestFlight for iOS; and
  a run on real phones, tablets and a real receipt printer, which has not
  happened yet.

## License

Proprietary — © DukanPro. Not for redistribution.
