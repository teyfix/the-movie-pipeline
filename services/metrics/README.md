# Observability collector

Prometheus, Loki and Grafana keep their existing upstream services. The `vector` collector uses published `teyfix/vector`; the shared image owns Process Compose, staging/native validation, watching, readiness, reload and shutdown. The consumer shell watcher is removed.

`config/collector.yaml` selects a native gomplate render command. Static Vector fragments and the NGINX/storage templates remain under `vector/`; `render.json.tmpl` emits the shared filename/object interface. Templates use `.tmpl`. Rendering writes only into the image's private runtime directory. The image owns Vector API configuration and `/data`; consumer fragments own sources, transforms, outputs and metrics. All collector source and values are watched, while changing `collector.yaml` requires a restart.

The collector reads PostgreSQL, pipeline engine and cache-proxy JSON files, plus labeled Docker logs. TEI log paths now use the same shared access-log format as TMDB. NGINX retry timings are paired by attempt index before conversion to seconds; missing timings do not produce upstream histograms. Scheduled `du` sources report cache storage, including an explicit unavailable/zero result when a path cannot be read. Loki labels and the `vector.lokal:9598` Prometheus scrape target stay the same.

Vector disk buffers/checkpoints live in `.state/metrics/vector/data`; native collector JSON logs live in `.state/metrics/vector/logs`. The old `vector` named volume is retained. Starting with a fresh checkpoint directory can replay retained source logs; migrate the old Vector data only while stopped if preserving checkpoints/buffers is needed. Keep reusable TEI/TMDB caches under `.cache`. `down -v` does not erase bind-mounted state; stop services before any explicit scoped reset.

Run `bun run observability:check` for the production configuration integration test. It uses isolated log/cache/state paths, a mock TEI origin and real Loki; verifies file log delivery, NGINX retry timing pairs, request/cache-storage metrics, last-valid retention and native reload; then removes only its temporary Compose stack. Test receipts and diagnostics remain under ignored `.state/observability-tests`. No model or GPU is required.

Grafana still provisions its datasources and [pipeline dashboard](grafana/provisioning/dashboards/tmdb/pipeline.json). [Prometheus configuration](prometheus/prometheus.yaml) owns the service scrape jobs, and [Loki configuration](loki/config.yaml) owns ingestion limits and retention. Grafana, Loki and Prometheus retain their `grafana`, `lokidata` and `prometheus` named volumes and existing internal networks.

Access stays on `https://grafana.${TRAEFIK_BASE_DOMAIN}` and `https://prometheus.${TRAEFIK_BASE_DOMAIN}` through Traefik, or their existing `grafana.127-0-0-1.sslip.io:8000` and `prometheus.127-0-0-1.sslip.io:8000` reverse-proxy routes.
