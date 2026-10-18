# TMDB caches

Two instances of the published `teyfix/cache-proxy` image replace the native NGINX configuration. Compose selects a tested catalog revision; [the shared contract](https://github.com/teyfix/containers/blob/main/svc/cache-proxy/README.md) owns rendering, validation, readiness and log fields.

| Service      | Internal URL                   | Configuration       | Upstream                     |
| ------------ | ------------------------------ | ------------------- | ---------------------------- |
| `tmdb`       | `http://tmdb.lokal:8080`       | `config/api.yaml`   | `https://api.themoviedb.org` |
| `tmdb-files` | `http://tmdb-files.lokal:8080` | `config/files.yaml` | `https://files.tmdb.org`     |

The existing Traefik `api.<base-domain>`/`files.<base-domain>` and fallback NGINX hostnames remain available. Seed now uses the files service on 8080 instead of `tmdb.lokal:9090`. The `enrich` CUE configuration calls the API cache without a caller Authorization header: the cache adds the configured `TMDB_API_SECRET` as the upstream Bearer credential. This explicitly permits shared caching of TMDB's public catalog responses. Incoming caller Authorization/Cookie headers still trigger the image's cache bypass.

Both routes retain 30-day success lifetimes/inactivity, 1-hour 404 caching, 1-minute server-error caching, 30-second cache locks and stale/background update policies. API storage is capped at 20 GB, downloads at 2 GB. The shared image overrides upstream freshness while still refusing responses marked private/no-store/no-cache or carrying Set-Cookie. It no longer unconditionally ignores those privacy directives. `enrich` continues to own its 40 RPS rate limit.

Reusable responses live under `.cache/tmdb/{api,files}`; access/error logs live under `.state/tmdb/{api-logs,files-logs}`. Vector reads `cache-proxy-access.jsonl` from both log directories and reports storage usage from the new cache paths. Healthchecks use the image's local `/healthz` endpoint and do not fetch from TMDB.

The old named cache/log volumes remain intact. The shared image uses a different request identity and starts a new cache namespace; no old entries are deleted or claimed to be reusable. Preserve `.cache/` when resetting disposable `.state`.

The TEI cache remains on its native configuration in this first adoption. Its explicit treatment of inference response `no-store` needs separate compatibility work before using the shared cache contract.
