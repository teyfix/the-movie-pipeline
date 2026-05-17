#!/usr/bin/env sh
set -eu

find "/app" -type f -name '*.gotpl' | while read -r tpl; do
  out="/tmp${tpl%.gotpl}"
  gomplate -f "$tpl" -o "$out"
  echo "Rendered: $tpl -> $out"
done

exec /bin/sh /entrypoint.sh /usr/bin/pgbouncer /etc/pgbouncer/pgbouncer.ini
