# Text Embeddings Inference (TEI)

Provides cached vector embeddings via a HuggingFace TEI server fronted by nginx.

## Architecture

- **`tei-server`** — Runs `ghcr.io/huggingface/text-embeddings-inference:1.9.2`.
  - Model: `BAAI/bge-large-en-v1.5`
  - Dimensions: `1024` (max padded to `2048`)
  - GPU reservations enabled in Compose (falls back to CPU if unavailable).
- **`tei`** — Nginx caching reverse proxy.

## Caching Strategy

TEI's `/embed` endpoint is `POST`-only. Nginx is configured to cache POST requests:

- **Cache key:** `${EMBEDDING_MODEL}|$scheme$proxy_host$uri|$request_body`
  - Embeddings are deterministic for a given model + input, so the request body is a perfect cache discriminator.
- **Cache zone:** `tei_cache` (1GB max, 30d inactive).
- **Methods:** `proxy_cache_methods POST`
- **Validity:** 200/201/204 cached for 1 day.
- **Stampede protection:** `proxy_cache_lock on` with 30s timeouts.
- **Stale serving:** Serves stale cache on TEI errors, timeouts, or 5xx.

## Headers

- `X-Cache-Status` added to responses: `HIT`, `MISS`, `EXPIRED`, etc.

## Access

- Traefik: `https://tei.tmdb.127-0-0-1.sslip.io`
- Direct: `http://tei.127-0-0-1.sslip.io:8000`

## Logs

JSON access logs include upstream timing and cache status.

> [!TIP]  
> When nginx makes multiple upstream attempts (due to timeouts or connection failures), the `urt`, `uct`, and `uht` fields will contain comma-separated values — one per attempt. A `-` indicates the value was unavailable for that attempt.

Example:

```json
{
  "args": "",
  "bytes_sent": 12728,
  "cache": "MISS",
  "method": "POST",
  "proxy_host": "tei-server.lokal:8080",
  "remote_addr": "172.21.0.3",
  "rt": 0.067,
  "status": 200,
  "time": "2026-04-29T13:49:35+00:00",
  "uct": "0.000",
  "uht": "0.067",
  "uri": "/embed",
  "urt": "0.067",
  "user_agent": "Go-http-client/1.1"
}
```

## Dependencies

- `net-tei` — Internal Docker network.
- Volumes: `tei_log`, `tei_data`, `tei_cache`.
