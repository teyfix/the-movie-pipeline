# TEI cache

The inference server remains the official TEI image with its existing NVIDIA reservation; there is no automatic CPU fallback in this Compose configuration. `EMBEDDING_MODEL` and `EMBEDDING_DIMENSIONS` select the consumer model/embedding contract. The `tei` proxy uses published `teyfix/cache-proxy` and mounts the `tei-routes` Compose config. Compose substitutes `EMBEDDING_MODEL` into its cache namespace, so changing models and recreating the proxy cannot reuse the previous model's results. No consumer NGINX template remains.

Only the read-only `POST /embed` endpoint is cached. The shared key hashes the complete buffered request body and includes method, content type, request URI and model/configuration identity. Successes stay fresh for one day, inactive entries expire after 30 days, and responses use a 1 GiB cache. Concurrent fills use a 30-second native cache lock. Expired results can be served on upstream errors/timeouts/5xx. Other endpoints, including `/health` and `/metrics`, pass through uncached. `/healthz` is the proxy's local readiness endpoint; it does not assert inference readiness.

Client Authorization/Cookie and explicit cache-bypass requests bypass reads and writes. Private/no-store/no-cache and Set-Cookie responses are not stored, including with a TTL override. The removed legacy template claimed TEI always sends `no-store`; the pinned v1.9.2 HTTP router source does not establish that claim. The shared privacy policy remains in force; an upstream that adds those directives will be called for each request.

Models persist in `.cache/tei/models` at the inference server's `/data`, and responses persist in `.cache/tei/responses` at the proxy's `/var/cache/nginx`. Proxy JSON access logs and native text errors live in `.state/tei/logs`. The collector reads the JSON access log for TEI request/cache metrics and Loki delivery. Health checks are excluded from proxy access logs.

Old `tei_data`, `tei_cache` and `tei_log` named volumes are retained. Before starting the new mounts, copy any retained model files from the old `/data` into `.cache/tei/models`; stop the old services first and keep the source volume until verified. The old response-cache format/key is incompatible, so the new response cache starts cold; preserve the old volume rather than deleting it. The development host's old model/response volumes were empty during adoption. Preserve `.cache` across resets; bind-mounted `.state` requires scoped cleanup after stopping services.

`bun run observability:check` verifies the published proxy with a mock inference origin and a real Loki service. It covers body/model identity, credential bypass, privacy, concurrent fills, stale responses and uncached health/metrics. It does not download a model or test GPU inference.

Access stays on `https://tei.${TRAEFIK_BASE_DOMAIN}` through Traefik or `http://tei.127-0-0-1.sslip.io:8000` through the internal reverse proxy. Both services retain their `net-tei` aliases.

Access logs retain timing/cache fields and add host/route identity. Durations are seconds; upstream retry values are comma-separated, with missing values represented by `-` or an empty string. For example:

```json
{ "args": "", "bytes_sent": 12728, "cache": "MISS", "host": "tei.lokal", "method": "POST", "proxy_host": "route_embeddings", "route": "embeddings", "rt": 0.067, "status": 200, "time": "2026-10-18T00:00:00Z", "uct": "0.000", "uht": "0.067", "uri": "/embed", "urt": "0.067" }
```
