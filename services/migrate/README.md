# Database Migrations

Manages the PostgreSQL schema using **Drizzle ORM** and **Drizzle Kit**.

## Stack

- **Runtime:** Bun
- **ORM:** Drizzle ORM (`drizzle-orm`) with `pg-core`
- **Validation:** `@sinclair/typebox` for JSON schema checks
- **Dialect:** PostgreSQL (Supabase image)

## Schema Conventions

- **`auditColumns`** — `created_ts`, `updated_ts` (auto-managed by DB defaults).
- **`versionColumn`** — `version_ts` ingestion watermark. Used to join tables idempotently and suppress stale out-of-order data.
- **Custom Shapes:**
  - `languageCode()` — ISO 639-1
  - `countryCode()` — ISO 3166-1 alpha-2
  - `imagePath()` — TMDB image path
  - `mongoId()` — Stored as `uuid` (padded to 32 chars)
- **Enums:** `title_kind`, `company_kind`, `facet_kind`, `person_field`, `title_field`, etc.
- **Views:** `title_translation_view` aggregates per-locale translations into JSONB arrays.

## Extensions

Initialized automatically via `services/postgres/postgres/tmdb/0000-init/`:

- `vector` (pgvector) — `halfvec(2048)` for embeddings.
- `pgroonga` — Full-text search.
- `pg_jsonschema` — JSONB validation via `jsonb_matches_schema()`.

## Workflow

```bash
task migrate     # generate + format + run
task migrate:gen # generate only
```

Migrations are stored in `app/drizzle/<timestamp>_<name>/`. The `snapshot.json` file inside each migration directory is truncated in this repository to reduce file size.

## Configuration

- `drizzle.config.ts` — Reads `POSTGRES_URL` from environment.
- `src/config.ts` — Validates `POSTGRES_URL`, `POSTGRES_SCHEMA`, `MIGRATION_PATH`, `EMBEDDING_DIMENSIONS_MAX`.
