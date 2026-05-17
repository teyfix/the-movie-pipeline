# Redpanda (Kafka)

Kafka-compatible event streaming platform. Single-node `dev-container` mode suitable for local development and moderate throughput.

## Listeners

| Purpose         | Internal Address               | External Address (Traefik)                 |
| --------------- | ------------------------------ | ------------------------------------------ |
| Kafka API       | `kafka.lokal:9092` (plain TCP) | `kafka.tmdb.127-0-0-1.sslip.io:4040` (TLS) |
| HTTP Proxy      | `kafka.lokal:8082`             | —                                          |
| Schema Registry | `kafka.lokal:8081`             | —                                          |
| Admin API       | `kafka.lokal:9644`             | —                                          |

**Critical:** Clients inside the Docker network must use `kafka.lokal:9092`. External clients must use the Traefik TLS endpoint. Using the wrong address causes metadata mismatches and connection failures.

## Console UIs

- **Kafka UI** (default, always started): `https://kafka-ui.tmdb.127-0-0-1.sslip.io` or `http://kafka-ui.127-0-0-1.sslip.io:8000`
  - Config: `kafka-ui/config.yaml`
- **Redpanda Console** (optional, `--profile console`): `https://redpanda.tmdb.127-0-0-1.sslip.io` or `http://redpanda-console.127-0-0-1.sslip.io:8000`
  - Connects internally to `kafka.lokal:9092`.

## Topic Provisioning

The `kafka-init` service reads `services/pipeline/values/tmdb.yaml` and auto-creates all topics:

- Partitions: `3` (configurable)
- Cleanup policy: `compact`
- Compression: `zstd`
- Max message bytes: `104857600` (100MB)
- Segment sizes: 16MB for small topics, 512MB for detail/normalized topics.

It also expands partitions if `KAFKA_NUM_PARTITIONS` is increased.

## Metrics

Redpanda exposes Prometheus metrics on `:9644` at `/public_metrics` and `/metrics`.

## Resources

- CPU: `4` (configurable)
- Memory: `4G` (configurable)
