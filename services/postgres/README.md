# PostgreSQL and pooling

The published `teyfix/postgres` image runs PostgreSQL 17, PgBouncer, postgres-exporter and PgBouncer exporter in one supervised container. Compose selects the tested catalog revision; [the shared contract](https://github.com/teyfix/containers/blob/main/svc/postgres/README.md) owns its lifecycle and configuration schema.

`config/postgres.yaml` owns this project's `tmdb` database/application role, `tmdb` and `drizzle` schemas, grants/search paths and the vector, pgroonga, pg_jsonschema and pg_stat_statements extensions. Passwords come from `POSTGRES_PASSWORD` and `PG_PASSWORD`. If changing database/role/schema names, update this YAML and the matching `.env` connection settings together.

The administrator is `postgres`; Supabase application bootstrap and its `supabase_admin` role are replaced. Drizzle remains the application schema owner in the separate `migrate` service, which connects directly as `postgres`. The pipeline uses `tmdb` through transaction pooling. Existing local `.env` files can retain obsolete image/pooler/admin variables: Compose constructs the new migration and ingestion URLs explicitly. When using the exported `POSTGRES_ADMIN_URL` or `POSTGRES_URL` elsewhere, update them to the new administrator and pooler port shown in `.example.env`.

| Interface               | Internal address                  |
| ----------------------- | --------------------------------- |
| PostgreSQL              | `postgres.lokal:5432`             |
| PgBouncer               | `pgbouncer.lokal:6432`            |
| PostgreSQL metrics      | `postgres.lokal:9187/metrics`     |
| Pooler metrics          | `pgbouncer.lokal:9127/metrics`    |
| Application SQL metrics | `postgres-sql.lokal:9399/metrics` |

The existing Traefik hostnames remain `pg.<base-domain>` and `pgbouncer.<base-domain>`. They now route to two ports on the `postgres` container. The image healthcheck covers provisioning, database access, pooling and successful native metric scrapes. Use `docker compose exec postgres ...` for both database and pooler diagnostics; the old separate `pgbouncer` and exporter services are gone.

`postgres-sql` uses native SQL Exporter and the consumer-owned `metrics/tmdb.collector.yaml`, preserving the dashboard's `pg_custom_*` metric names. It starts after Drizzle finishes, because its title/person queries require application tables. Enabling these collectors inside the database bundle while requiring database health before Drizzle would create a startup dependency cycle. Standard exporters use the bundle's restricted identities; application queries use the existing application role rather than the administrator.

Data and logs live under `.state/postgres/{data,logs,pooler-logs}`. Vector reads PostgreSQL JSON logs through a read-only bind mount. This image starts a fresh cluster; it does not import the former Supabase `pgdata` volume. The old named volumes are left intact. Rebuild disposable development state through normal provisioning and Drizzle, or explicitly export/import wanted data separately.

`docker compose down -v` does not delete `.state` bind mounts. For a database reset, stop this project's services, explicitly remove its `.state/postgres/data`, then start again. Preserve `.cache/` and unrelated state.
