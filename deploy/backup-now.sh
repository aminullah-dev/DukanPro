#!/usr/bin/env bash
# A backup right now, beside the daily ones: before an update, say.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p backups
file="backups/dukan-manual-$(date -u +%Y%m%dT%H%MZ).sql.gz"
docker compose exec -T db pg_dump -U dukan --no-owner dukan | gzip > "$file.part"
mv "$file.part" "$file"
echo "Saved $file"
