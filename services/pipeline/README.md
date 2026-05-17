# Data Pipeline

End-to-end streaming pipeline that moves TMDB data from daily exports into PostgreSQL.

## Stages

### 1. Seed (`seed` service)

Downloads daily ID exports from `files.tmdb.org` and publishes them to Kafka.

- **Input:** Scheduled `curl` to `files.tmdb.org/p/exports/{prefix}_ids_MM_DD_YYYY.json.gz`
- **Prefixes:** `movie`, `adult_movie`, `tv_series`, `adult_tv_series`, `person`, `adult_person`, `collection`, `tv_network`, `keyword`, `production_company`
- **Output:** `tmdb.export.{kind}` topics
- **Tool:** Vector (`exec` + `file` sources, `kafka` sink)
- **Metrics:** `tmdb_downloads_total` counter per kind/status

### 2. Enrich (`enrich` service)

Consumes export IDs and fetches full TMDB API documents.

- **Input:** `tmdb.export.*`
- **Output:** `tmdb.detail.*`
- **Rate limit:** 40 req/s against TMDB API (`tmdb` resource)
- **API:** `http://tmdb.lokal:8080` (internal nginx cache)
- **Passthrough:** `keyword`, `production-company`, `tv-network` skip API calls and forward export data directly.
- **Special case:** `season` is enriched from `show` normalized data (`/3/tv/{id}/season/{num}`).

### 3. Normalize (`normalize` service)

Flattens and cleans API responses.

- **Input:** `tmdb.detail.*`
- **Output:** `tmdb.normalized.*`
- **Unwrap:** Converts `results`, `keywords.keywords`, `lists.results`, etc. into top-level arrays.
- **Sanitize:** Replaces empty strings `""` with `null`.
- **Reviews:** Flattens `author_details` into `author_*` fields.
- **Release dates:** Flattens nested `release_dates` array.

### 4. Embed (`embed` service, optional — `--profile embed`)

Generates text embeddings for movies.

- **Input:** `tmdb.normalized.movie`
- **Output:** `tmdb.embed.movie`
- **TEI:** Calls `http://tei.lokal:8080/embed` with a structured input (title, overview, cast, genres, keywords, lists, reviews).
- **Rate limit:** 10 req/s against TEI (`tei` resource)
- **Cache:** TEI nginx caches POST responses by request body.

### 5. Ingest (`ingest` service)

Loads normalized data into PostgreSQL.

- **Input:** `tmdb.normalized.*` and `tmdb.embed.*`
- **Output:** PostgreSQL via PgBouncer
- **Mapping:** Bloblang (`.blobl`) files transform JSON into table rows.
- **Deduplication:** Groups by primary key, sorts by `version_ts`, keeps latest.
- **Upsert:** `sql_insert` with `ON CONFLICT (...) DO UPDATE SET ...`
- **Connection limits:** `conn_max_open=3`, `conn_max_idle=2`, `conn_max_life_time=2m` to protect PgBouncer.

## Configuration

All resource definitions (topics, endpoints, consumer groups, batch sizes) live in `values/tmdb.yaml`. Gomplate renders per-resource configs from `.gotpl` templates.

## Topic Naming Convention

| Stage      | Topic Pattern             |
| ---------- | ------------------------- |
| Export     | `tmdb.export.{kind}`      |
| Detail     | `tmdb.detail.{kind}`      |
| Normalized | `tmdb.normalized.{kind}`  |
| Embed      | `tmdb.embed.{kind}`       |
| DLQ        | `tmdb.{stage}.{kind}-dlq` |

## Idempotency

The pipeline is fully restart-safe:

- Kafka topics use `cleanup.policy=compact`.
- TMDB API responses are cached for 30 days.
- Ingestion uses `version_ts` to ignore stale data.
