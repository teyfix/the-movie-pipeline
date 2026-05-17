#!/usr/bin/env sh
set -eu

log_entry() {
  local level="$1" module="$2" message="$3"
  jq -cn \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg level "$level" \
    --arg module "$module" \
    --arg message "$message" \
    '{ts: $ts, level: $level, module: $module, msg: $message}'
}

log_stream() {
  local module="$1" level="${2:-info}"
  while IFS= read -r line; do
    log_entry "$level" "$module" "$line"
  done
}

info() {
  log_entry "info" "entrypoint" "$@"
}

GOMPLATE_CONFIG="/app/values/.gomplate.yaml"
APP_CONFIG="/app/config/"
TMP_STAGE="/tmp/config_stage/"
TMP_CONFIG="/tmp/config/"

render() {
  rsync -av --delete "$APP_CONFIG" "$TMP_STAGE" \
    | log_stream rsync:stage info

  find "$TMP_STAGE" -type f -name '*.gotpl' | while read -r tpl; do
    out="${tpl%.gotpl}"
    gomplate --config "$GOMPLATE_CONFIG" -f "$tpl" -o "$out"
    rm "$tpl"
    info "Rendered: $tpl -> $out"
  done

  rsync -av --delete "$TMP_STAGE" "$TMP_CONFIG" \
    | log_stream rsync:target info
}

watch() {
  while inotifywait -q -r -e modify,create,delete "$APP_CONFIG" 2>&1 | log_stream "inotify" "info"; do
    info "Config change detected, re-rendering..."
    render
  done
}

render
watch &

exec vector -w -c "$TMP_CONFIG**/*.yaml"
