# Metrics & Observability

This directory contains the full observability stack: **Prometheus**, **Grafana**, **Loki**, and **Vector**.

## Architecture

- **Prometheus** scrapes metrics from every service in the stack.
- **Grafana** provisions datasources (Prometheus, Loki) and dashboards. The provisioned dashboard JSON is located at [`grafana/provisioning/dashboards/tmdb/pipeline.json`](grafana/provisioning/dashboards/tmdb/pipeline.json).
- **Loki** aggregates logs with filesystem storage, 168-hour retention, and support for large log lines (up to 2MB).
- **Vector** ships logs and metrics. It reads Docker container logs (via `docker.sock`), nginx access logs, PostgreSQL JSON logs, and storage usage metrics, then forwards them to Loki and a Prometheus exporter.

## Vector Configuration

Vector uses **gomplate** to render `.gotpl` templates at runtime:

- `nginx.yaml.gotpl` — Parses JSON access logs, expands multi-attempt upstream timings (`urt`, `uct`, `uht`), and emits Prometheus histograms.
- `storage.yaml.gotpl` — Runs `storage.sh` periodically to report cache volume sizes.
- `entrypoint.sh` — Renders configs on startup and watches for changes via `inotifywait`.

## Log Routing

| Source                 | Transform         | Destination       |
| ---------------------- | ----------------- | ----------------- |
| Docker logs            | `enrich_docker`   | Loki              |
| Nginx logs (TEI, TMDB) | `enrich_nginx`    | Loki + Prometheus |
| Postgres JSON logs     | `enrich_postgres` | Loki              |
| Storage `du` exec      | `du_parse_all`    | Prometheus        |

## Key Files

- `prometheus/prometheus.yaml` — Scrape configs for all jobs (Redpanda, Postgres, PgBouncer, Vector, TEI, pipeline workers).
- `grafana/provisioning/` — Dashboard and datasource definitions.
- `loki/config.yaml` — Loki server config with ingestion limits and retention.
- `vector/config/` — Vector sources, transforms, sinks, and the hot-reload entrypoint.

## Access

- **Grafana:** `https://grafana.${TRAEFIK_BASE_DOMAIN}` or `http://grafana.127-0-0-1.sslip.io:8000`
- **Prometheus:** `https://prometheus.${TRAEFIK_BASE_DOMAIN}` or `http://prometheus.127-0-0-1.sslip.io:8000`

## Dependencies

- `net-grafana`, `net-loki`, `net-prometheus`, `net-vector` — Internal Docker networks.
- Volumes: `grafana`, `lokidata`, `prometheus`, `vector`.
