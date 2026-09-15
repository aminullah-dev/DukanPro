#!/bin/sh
# Bring the database to this code's schema, then serve. Migrations are
# forward-only, and a database already at head is left as it is.
set -e
alembic upgrade head
exec uvicorn dukan.composition:app \
  --host 0.0.0.0 --port 8000 \
  --proxy-headers --forwarded-allow-ips="${DUKAN_FORWARDED_ALLOW_IPS:-*}" \
  --workers "${DUKAN_WORKERS:-2}"
