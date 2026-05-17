# Internal Reverse Proxy

A lightweight **nginx** gateway that exposes HTTP services when you do **not** want to run the full Traefik stack.

## Exposed Services

All services are available on **port 8000**, routed by `Host` header:

| Subdomain                             | Upstream                      | Service          |
| ------------------------------------- | ----------------------------- | ---------------- |
| `prometheus.127-0-0-1.sslip.io`       | `prometheus.lokal:9090`       | Prometheus       |
| `grafana.127-0-0-1.sslip.io`          | `grafana.lokal:3000`          | Grafana          |
| `pgadmin.127-0-0-1.sslip.io`          | `pgadmin.lokal:80`            | pgAdmin          |
| `redpanda-console.127-0-0-1.sslip.io` | `redpanda-console.lokal:8080` | Redpanda Console |
| `kafka-ui.127-0-0-1.sslip.io`         | `kafka-ui.lokal:8080`         | Kafka UI         |
| `tei.127-0-0-1.sslip.io`              | `tei.lokal:8080`              | TEI              |
| `tmdb-api.127-0-0-1.sslip.io`         | `tmdb.lokal:8080`             | TMDB API Proxy   |
| `tmdb-files.127-0-0-1.sslip.io`       | `tmdb.lokal:9090`             | TMDB Files Proxy |

## Health Check

Port `4000` exposes `/health` for Docker healthchecks.

## Logs

- `proxy_log` — JSON format including upstream connect/header/response times and cache status.
- `health_log` — Minimal JSON for health endpoint.

## DNS

Uses Docker's internal resolver (`127.0.0.11`) to resolve `.lokal` aliases dynamically.

## Traefik Alternative

For TLS termination and automatic routing, use [teyfix/traefik](https://github.com/teyfix/traefik) instead. In that setup, this nginx service is optional for HTTP ingress, but still useful as a fallback.
