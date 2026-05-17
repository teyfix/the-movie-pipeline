#!/usr/bin/env bash
set -euo pipefail

PSQL_ARGS=(
  -v ON_ERROR_STOP=1
  --dbname "$POSTGRES_DB"
  --username "$POSTGRES_USER"
)

while IFS= read -r tpl; do
  case "$tpl" in
    *.sql.gotpl)
      gomplate -f "$tpl" | psql "${PSQL_ARGS[@]}"
      ;;
    *.sql)
      psql "${PSQL_ARGS[@]}" -f "$tpl"
      ;;
    *)
      echo "Unknown file type: $tpl" >&2
      ;;
  esac
done < <(find "/docker-entrypoint-initdb.d/tmdb" -type f | sort)
