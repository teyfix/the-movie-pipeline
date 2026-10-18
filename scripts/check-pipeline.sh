#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
docker compose config --quiet
docker compose build kafka-init seed enrich normalize embed ingest
docker compose run --rm --no-deps --entrypoint /bin/bash kafka-init -c 'set -e; rpk version; cue vet ./shared/tmdb'
for service in seed enrich normalize embed ingest; do
  docker compose run --rm --no-deps --entrypoint /bin/bash "$service" -c 'set -e; /usr/local/libexec/teyfix/base/prepare.sh; /usr/local/libexec/teyfix/pipeline/render.sh'
done
