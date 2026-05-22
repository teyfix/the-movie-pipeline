#!/usr/bin/env bash
set -euo pipefail

: ${KIND:?Required variable KIND not set}
: ${PREFIX:?Required variable PREFIX not set}
: ${TMDB_DOWNLOAD_DIR:?Required variable TMDB_DOWNLOAD_DIR not set}
: ${TMDB_FILES_API_URL:?Required variable TMDB_FILES_API_URL not set}

log_status() {
  status="$1"

  jq -cn \
    --arg status "$status" --arg kind "$KIND" --arg prefix "$PREFIX" \
    '{status: $status, kind: $kind, prefix: $prefix}'
}

download_file="${TMDB_DOWNLOAD_DIR}/${PREFIX}_ids_$(jq -rn 'now | strftime("%m_%d_%Y")').json.gz"

# Skip if already downloaded
if [[ -f "$download_file" ]]; then
  log_status "skipped"
  exit 0
fi

staging_file="$(mktemp)"

date_today="$(jq -rn 'now | strftime("%m_%d_%Y")')"
date_yesterday="$(jq -rn 'now - 86400 | strftime("%m_%d_%Y")')"

trap 'rm -f "$staging_file"' EXIT

for date in "$date_today" "$date_yesterday"; do
  url="${TMDB_FILES_API_URL}/p/exports/${PREFIX}_ids_${date}.json.gz"
  dest="${TMDB_DOWNLOAD_DIR}/${PREFIX}_ids_${date}.json.gz"

  if wget -qO "$staging_file" "$url"; then
    mv "$staging_file" "$dest"
    log_status "success"
    exit 0
  fi
done

log_status "failure"
exit 1
