# Deploying the server

One Linux machine with Docker runs everything: PostgreSQL, the API, Caddy in front of it for HTTPS, and a daily backup. The files are in `deploy/`; the image is built from `server/`.

## What you need

- A Linux server (2 GB of memory is plenty for one shop) with Docker and the Compose plugin.
- A domain name, such as `api.yourshop.af`, whose DNS points at the server, with ports 80 and 443 open to it. Caddy uses them to get and renew the HTTPS certificate by itself.

## First start

1. Copy the repository, or just `server/` and `deploy/`, to the server.
2. In `deploy/`, copy `.env.example` to `.env` and fill it in:
   - `DUKAN_DOMAIN`: the domain above.
   - `DUKAN_SECRET_KEY`: `python3 -c "import secrets; print(secrets.token_urlsafe(48))"`. It signs sign-in tokens; changing it later signs everyone out.
   - `POSTGRES_PASSWORD`: another random value.
   - `DUKAN_BOOTSTRAP_TOKEN` (optional): the setup code for the first owner. Leave it out and read the code the server prints: `docker compose logs api`.
3. Start it: `docker compose up -d --build`. The API brings the database to its schema before it serves.
4. Check it: `https://<your domain>/health` answers `{"status": "ok", ...}`.
5. On the first device, choose first-run setup and enter the setup code, the shop's name and the owner's account.

## The app

Build the app against the server's address:

```bash
flutter build apk --dart-define=DUKAN_API=https://api.yourshop.af
```

The same `--dart-define` goes on `flutter build ios`, `macos` and `windows`. Devices keep working without the server and sync when they reach it (docs/sync-protocol.md).

## Updating

```bash
./backup-now.sh
git pull
docker compose up -d --build
```

The new API migrates the database as it starts. Migrations only move forward, so keep the backup until the update has settled.

## Backups

- The `backup` service writes a compressed dump to `deploy/backups/` once a day and keeps `BACKUP_KEEP_DAYS` days of them (14 by default). `./backup-now.sh` makes one on demand.
- Copy the backups off the machine as well: a disk that fails takes its backups with it.
- To restore, start from an empty database, then load the dump:
  ```bash
  docker compose down && docker volume rm dukanpro_db && docker compose up -d db
  ./restore.sh backups/dukan-20260915T0300Z.sql.gz
  ```
  `restore.sh` refuses a database that already has data. Devices notice the restore and read everything again; changes they had not synced are kept and sent.

## Security

- `.env` holds every secret. Keep it on the server only, readable by the account that runs Docker.
- Only Caddy is reachable from outside. The API and the database listen on the Compose network alone.
- Five wrong passwords close an account's online sign-in for 15 minutes (docs/domain/identity-access.md). The audit log shows the attempts.
