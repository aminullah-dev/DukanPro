#!/usr/bin/env bash
# Restores a backup into an empty database:
#   ./restore.sh backups/dukan-20260915T0300Z.sql.gz
# A database that already holds data is refused, so a restore never mixes two
# states of the shop. Devices notice the restore and read everything again.
set -euo pipefail
file=${1:?usage: ./restore.sh backups/dukan-<time>.sql.gz}
cd "$(dirname "$0")"
docker compose stop api
tables=$(docker compose exec -T db psql -U dukan -d dukan -tAc \
  "select count(*) from information_schema.tables where table_schema = 'public'")
if [ "$tables" != "0" ]; then
  echo "The database is not empty ($tables tables). To restore, start from an empty one:" >&2
  echo "  docker compose down && docker volume rm dukanpro_db && docker compose up -d db" >&2
  exit 1
fi
gunzip -c "$file" | docker compose exec -T db psql -U dukan -d dukan -v ON_ERROR_STOP=1 >/dev/null
docker compose start api
echo "Restored $file"
