#!/usr/bin/env sh
set -eu

mkdir -p /app/drizzle
chown -R bun:bun /app/drizzle || true

exec su bun -c "$@"
