# TMDB Cache Proxy

Caching reverse proxy for TMDB upstreams. Reduces API load and allows the pipeline to restart idempotently without re-fetching recent data.

## Upstreams

| Port   | Upstream             | Purpose                    |
| ------ | -------------------- | -------------------------- |
| `8080` | `api.themoviedb.org` | TMDB REST API (CloudFront) |
| `9090` | `files.tmdb.org`     | Daily ID export files (S3) |

## Caching

- **`tmdb_api`** zone: 20GB max, 500MB key index, 30d inactive.
- **`tmdb_files`** zone: 2GB max, 1MB key index, 30d inactive.
- **Policy:** Ignores upstream `Cache-Control` and forces caching.
- **Success:** 200/201/204 cached for 30 days.
- **Not found:** 404 cached for 1h (prevents repeated misses).
- **Errors:** 5xx cached for 1m (protects origin).
- **Stale:** Serves stale on error, timeout, updating, and 5xx.
- **SNI:** Enabled for CloudFront TLS (`proxy_ssl_server_name on`).

## Rate Limiting

The `enrich` service enforces a 40 RPS local rate limit. The nginx cache absorbs duplicate requests, so the actual upstream hit rate is very low after warm-up.

## Access

| Service    | Traefik                                 | Direct (nginx)                              |
| ---------- | --------------------------------------- | ------------------------------------------- |
| TMDB API   | `https://api.tmdb.127-0-0-1.sslip.io`   | `http://tmdb-api.127-0-0-1.sslip.io:8000`   |
| TMDB Files | `https://files.tmdb.127-0-0-1.sslip.io` | `http://tmdb-files.127-0-0-1.sslip.io:8000` |

You can also use [teyfix/traefik](https://github.com/teyfix/traefik) for automatic TLS routing.

## Logs

JSON access logs include upstream timing and cache status.

> [!TIP]  
> When nginx makes multiple upstream attempts (due to timeouts or connection failures), the `urt`, `uct`, and `uht` fields will contain comma-separated values — one per attempt. A `-` indicates the value was unavailable for that attempt.

Example:

```json
{
  "args": "append_to_response=alternative_titles,...",
  "bytes_sent": 10982,
  "cache": "MISS",
  "method": "GET",
  "proxy_host": "api.themoviedb.org",
  "remote_addr": "172.18.0.4",
  "rt": 0.267,
  "status": 200,
  "time": "2026-04-29T10:53:52+00:00",
  "uct": "0.081",
  "uht": "0.265",
  "uri": "/3/tv/4259",
  "urt": "0.267",
  "user_agent": "Go-http-client/1.1"
}
```

## Dependencies

- `net-tmdb` — Internal Docker network.
- Volumes: `tmdb_log`, `tmdb_cache`.
