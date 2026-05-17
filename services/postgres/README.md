# PostgreSQL & Connection Pooling

This directory contains the primary database, connection pooler, and admin tools.

## Postgres (Supabase Image)

Uses `supabase/postgres:17.6.1.072` for advanced extension support.

- **DB:** `tmdb`
- **Superuser:** `supabase_admin` (required for init scripts)
- **App user:** `tmdb`
- **Schema:** `tmdb` (application), `drizzle` (migrations)

### Extensions

- `vector` (pgvector) — `halfvec` type for embeddings up to 2048 dims.
- `pgroonga` — Fast full-text search.
- `pg_jsonschema` — JSONB validation via `jsonb_matches_schema()`.

### Init Scripts

On first boot, `tmdb.sh` executes sorted files in `postgres/tmdb/`:

1. `0000-init/0000-lockdown.sql` — Revokes public schema privileges.
2. `0000-init/0001-appuser.sql.gotpl` — Creates `tmdb` role, schemas, and default privileges.
3. `0000-init/0002-extensions.sql.gotpl` — Creates extensions.

## PgBouncer

Transaction-level connection pooler.

- **Pool mode:** `transaction`
- **Default pool size:** 40
- **Max client conn:** 1000
- **Max DB conn:** 80
- **Auth:** `scram-sha-256` via generated `userlist.txt`

## pgAdmin

Pre-configured with a `Development` server pointing to `postgres.lokal:5432`.

## Exporters

- **postgres-exporter** — Metrics on `:9187`, including custom queries for title/person counts.
- **pgbouncer-exporter** — Pool metrics on `:9127`.

## Access

| Method                 | Address                                  |
| ---------------------- | ---------------------------------------- |
| Internal (Docker)      | `postgres.lokal:5432`                    |
| Internal (PgBouncer)   | `pgbouncer.lokal:5432`                   |
| External (Traefik TLS) | `pg.tmdb.127-0-0-1.sslip.io:4040`        |
| External (Traefik TLS) | `pgbouncer.tmdb.127-0-0-1.sslip.io:4040` |

## Alternative Gateway

For HTTP services in this stack, you can also use [teyfix/traefik](https://github.com/teyfix/traefik) or the internal nginx proxy at `http://{service-name}.127-0-0-1.sslip.io:8000`. Note that PostgreSQL is a TCP service and requires Traefik for external TLS access.
